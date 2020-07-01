class Event < ApplicationRecord
  extend FriendlyId

  default_scope { order(id: :asc) }
  scope :hidden, -> { where.not(hidden_at: nil) }
  scope :not_hidden, -> { where(hidden_at: nil) }

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
  has_many :donations

  has_many :lob_addresses
  has_many :checks, through: :lob_addresses

  has_many :emburse_transactions

  has_many :sponsors
  has_many :invoices, through: :sponsors

  has_many :documents

  validate :point_of_contact_is_admin

  validates :name, :sponsorship_fee, presence: true
  validates :slug, uniqueness: true, presence: true, format: { without: /\s/ }

  before_create :default_values

  # Used by the api's '/event' POST route
  def self.create_send_only(event_name, user_emails)
    ActiveRecord::Base.transaction do
      # most common POC will be the POC for this event
      point_of_contact_id = Event.all.pluck(:point_of_contact_id).max_by {|i| Event.all.count(i) }

      event = Event.create(
        name: event_name,
        start: Date.current,
        end: Date.current,
        address: 'N/A',
        sponsorship_fee: 0.07,
        expected_budget: 100.0,
        has_fiscal_sponsorship_document: false,
        point_of_contact_id: point_of_contact_id,
        is_spend_only: true,
      )

      sender = User.find_by_id point_of_contact_id

      user_emails ||= []
      user_emails.each do |email|
        OrganizerPositionInvite.create(
          sender: sender,
          event: event,
          email: email
        )
      end

      event
    end
  end

  def self.pending_fees
    # minimum that you can move with SVB is $1
    select { |event| event.fee_balance > 100 }
  end

  # When a fee payment is collected from this event, what will the TX memo be?
  def fee_payment_memo
    "#{self.name} Bank Fee"
  end

  # displayed on /negative_events
  def self.negatives
    select { |event| event.balance < 0 || event.emburse_balance < 0 || event.fee_balance < 0 }
  end

  def emburse_department_path
    "https://app.emburse.com/budgets/#{emburse_department_id}"
  end

  def emburse_budget_limit
    # We want to count positive Emburse TXs that are either pending OR complete,
    # because pending TXs will silently switch to complete and the admin will not
    # be notified to update the Emburse budget for this event later when that happens.
    # See also PR #317.
    self.emburse_transactions.undeclined.where(emburse_card_id: nil).sum(:amount)
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

  # used for load card requests, this is the amount of money available that isn't being transferred out by an LCR or isn't going to be pulled out via fee -tmb@hackclub
  def balance_available
    lcr_pending = (load_card_requests.under_review + load_card_requests.pending).sum(&:load_amount)
    balance - lcr_pending - fee_balance
  end
  alias available_balance balance_available

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

  def g_suite_status
    return :start if g_suite_application.nil?
    return :under_review if g_suite_application.under_review?
    return :app_accepted if g_suite_application.accepted? && g_suite.present?
    return :app_rejected if g_suite_application.rejected?
    return :verify_setup if !g_suite.verified?
    return :done if g_suite.verified?

    :start
  end

  def plan_name
    if is_spend_only
      "spend-only"
    else
      "full fiscal sponsorship"
    end
  end

  def past?
    self.end < Time.current
  end

  def future?
    self.start > Time.current
  end

  def hidden?
    hidden_at.present?
  end

  def filter_data
    {
      exists: true,
      past: past?,
      future: future?,
      hidden: hidden?
    }
  end

  private

  def default_values
    self.has_fiscal_sponsorship_document ||= true
  end

  def point_of_contact_is_admin
    return if self.point_of_contact&.admin?

    errors.add(:point_of_contact, 'must be an admin')
  end
end
