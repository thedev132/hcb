class Event < ApplicationRecord
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

  has_many :emburse_transactions

  has_many :sponsors

  has_many :documents

  validates :name, :start, :end, :address, :sponsorship_fee, presence: true

  def emburse_budget
    self.emburse_transactions.completed.where('amount > 0').sum(:amount)
  end

  def emburse_balance
    emburse_debit = self.emburse_transactions.undeclined.where('amount < 0').sum(:amount)
    emburse_budget + emburse_debit
  end

  def balance
    self.transactions.sum(:amount)
  end

  def billed_transactions
    self.transactions
        .joins(:fee_relationship)
        .where(fee_relationships: { fee_applies: true } )
  end

  def fee_payments
    self.transactions
        .joins(:fee_relationship)
        .where(fee_relationships: { is_fee_payment: true } )
  end

  # total amount over all time paid agains the fee
  def fee_paid
    # fee payments are withdrawals, so negate value
    -self.fee_payments.sum(:amount)
  end

  def fee_balance
    total_fees = self.fee_relationships.sum(:fee_amount)
    total_payments = self.fee_paid

    total_fees - total_payments
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
end
