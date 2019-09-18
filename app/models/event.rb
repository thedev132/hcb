class Event < ApplicationRecord
  extend FriendlyId

  default_scope { order(id: :asc) }

  friendly_id :name, use: :slugged

  belongs_to :point_of_contact, class_name: 'User'

  has_many :organizer_position_invites
  has_many :organizer_positions
  has_many :users, through: :organizer_positions
  has_one :g_suite_application, required: false
  has_one :g_suite, required: false
  has_many :g_suite_accounts, through: :g_suite

  has_many :fee_relationships
  has_many :transactions, through: :fee_relationships, source: :t_transaction

  has_many :cards
  has_many :card_requests
  has_many :load_card_requests
  has_many :ach_transfers

  has_many :lob_addresses
  has_many :checks, through: :lob_addresses

  has_many :emburse_transactions

  has_many :sponsors
  has_many :invoices, through: :sponsors

  has_many :documents

  validate :point_of_contact_is_admin

  validates :name, :start, :end, :address, :sponsorship_fee, presence: true
  validates :slug, uniqueness: true, presence: true, format: { without: /\s/ }

  before_create :default_values

  def self.pending_fees
    # minimum that you can move with SVB is $1
    select { |event| event.fee_balance > 100 }
  end

  def emburse_department_path
    "https://app.emburse.com/budgets/#{emburse_department_id}"
  end

  def emburse_budget_limit
    self.emburse_transactions.completed.where(emburse_card_id: nil).sum(:amount)
  end

  def emburse_balance
    completed_t = self.emburse_transactions.completed.sum(:amount)
    # We're including only pending charges on cards so organizers have a conservative estimate of their balance
    pending_t = self.emburse_transactions.pending.where('amount < 0').sum(:amount)
    completed_t + pending_t
  end

  def balance
    transactions.sum(:amount)
  end

  def lcr_pending
    (
      load_card_requests.under_review +
      load_card_requests.accepted -
      load_card_requests.completed -
      load_card_requests.canceled -
      load_card_requests.rejected
    )
      .sum(&:load_amount)
  end

  # used for load card requests, this is the amount of money available that isn't being transferred out by an LCR or isn't going to be pulled out via fee -tmb@hackclub
  def balance_available
    balance - lcr_pending - fee_balance
  end
  alias available_balance balance_available

  # amount incoming from paid Stripe invoices not yet deposited
  def pending_deposits
    # money that is pending payout- aka payout has not been created yet
    pre_payout = invoices.where(status: 'paid', payout: nil).sum(:amount_paid)

    # money that has a payout created, but where the transaction has not hit the account yet / been associated with the pending payout
    payout_created = invoices.joins(payout: :t_transaction).where(status: 'paid', payout: { transactions: { id: nil } }).sum(:amount_paid)

    pre_payout + payout_created
  end

  def billed_transactions
    transactions
      .joins(:fee_relationship)
      .where(fee_relationships: { fee_applies: true })
  end

  def fee_payments
    transactions
      .joins(:fee_relationship)
      .where(fee_relationships: { is_fee_payment: true })
  end

  # total amount over all time paid agains the fee
  def fee_paid
    # fee payments are withdrawals, so negate value
    -self.fee_payments.sum(:amount)
  end

  def fee_balance
    total_fees = self.billed_transactions.sum('fee_relationships.fee_amount')
    total_payments = self.fee_paid

    total_fees - total_payments
  end

  # amount of balance that fees haven't been pulled out for
  def balance_not_feed
    a_fee_balance = self.fee_balance

    self.transactions.where.not(fee_reimbursement: nil).each do |t|
      a_fee_balance -= (100 - t.fee_reimbursement.amount) if t.fee_reimbursement.amount < 100
    end

    percent = self.sponsorship_fee * 100

    (a_fee_balance * 100 / percent)
  end

  def fee_balance_without_fee_reimbursement_reconcilliation
    a_fee_balance = self.fee_balance
    self.transactions.where.not(fee_reimbursement: nil).each do |t|
      a_fee_balance -= (100 - t.fee_reimbursement.amount) if t.fee_reimbursement.amount < 100
    end

    a_fee_balance
  end

  def balance_being_withdrawn
    lcrs = load_card_requests
    fee_balance + lcr_pending
  end

  def g_suite_status
    return :start if g_suite_application.nil?
    return :under_review if g_suite_application.under_review?
    return :app_accepted if g_suite_application.accepted? && g_suite.present?
    return :app_rejected if g_suite_application.rejected?
    return :verify_setup if !g_suite.verified?
    return :done if g_suite.verified?

    :start
  end

  def past?
    self.end < Time.current
  end

  def future?
    self.start > Time.current
  end

  def filter_data
    {
      exists: true,
      past: past?,
      future: future?
    }
  end

  private

  def default_values
    self.has_fiscal_sponsorship_document = true
  end

  def point_of_contact_is_admin
    return if self.point_of_contact&.admin?

    errors.add(:point_of_contact, 'must be an admin')
  end
end
