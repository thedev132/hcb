class Transaction < ApplicationRecord
  extend FriendlyId

  paginates_per 100

  friendly_id :slug_text, use: :slugged

  acts_as_paranoid

  default_scope { order(date: :desc, id: :desc) }
  scope :uncategorized, -> { where(is_event_related: true, fee_relationship_id: nil) }

  belongs_to :bank_account

  belongs_to :fee_relationship, inverse_of: :t_transaction, required: false
  has_one :event, through: :fee_relationship

  belongs_to :load_card_request, inverse_of: :t_transaction, required: false
  belongs_to :invoice_payout, inverse_of: :t_transaction, required: false

  belongs_to :fee_reimbursement, inverse_of: :t_transaction, required: false

  belongs_to :check, inverse_of: :t_transactions, required: false
  belongs_to :ach_transfer, inverse_of: :t_transaction, required: false

  has_many :comments, as: :commentable

  accepts_nested_attributes_for :fee_relationship

  validates :plaid_id, uniqueness: true
  validates :is_event_related, inclusion: { in: [true, false] }

  validates :fee_relationship,
            absence: true,
            unless: -> { self.is_event_related }

  validate :ensure_paired_correctly

  after_initialize :default_values
  after_create :notify_admin

  def self.total_volume
    self.sum('@amount')
  end

  def self.during(start_time, end_time)
    self.where(["transactions.created_at > ? and transactions.created_at < ?", start_time, end_time])
  end

  def self.volume_during(start_time, end_time)
    self.during(start_time, end_time).sum('@amount')
  end

  def self.raised_during(start_time, end_time)
    raised_during = self.during(start_time, end_time)
      .includes(:fee_relationship)
      .where(
        is_event_related: true,
        fee_relationships: {
          fee_applies: true,
        },
    )

    raised_during.sum(:amount)
  end

  def self.revenue_during(start_time, end_time)
    fees_during = self.during(start_time, end_time)
      .includes(:fee_relationship)
      .where(
        is_event_related: true,
        fee_relationships: {
          is_fee_payment: true,
        },
    )

    # revenue for Bank is expense for Events
    -fees_during.sum(:amount)
  end

  delegate :url_helpers, to: 'Rails.application.routes'
  def link
    host = Rails.application.config.action_mailer.default_url_options[:host]
    host + url_helpers.transaction_path(self)
  end

  def default_values
    self.is_event_related = true if self.is_event_related.nil?
    set_default_display_name
  end

  def set_default_display_name
    self.display_name = "Transfer from account to card balance" if emburse?
    self.display_name ||= self.name
  end

  def notify_admin
    TransactionMailer.with(transaction: self).notify_admin.deliver_later
  end

  def notify_user_invoice
    MoneyReceivedMailer.with(transaction: self).money_received.deliver_later
  end

  # Utility method for getting the fee on the transaction if there is one. Used
  # in CSV export.
  def fee
    is_event_related && fee_relationship&.fee_applies && fee_relationship&.fee_amount
  end

  def fee_payment?
    is_event_related && fee_relationship&.is_fee_payment
  end

  def fee_applies?
    is_event_related && fee_relationship&.fee_applies
  end

  def categorized?
    is_event_related && fee_relationship_id
  end

  def filter_data
    {
      exists: true,
      fee_applies: self.fee_applies?,
      fee_payment: self.fee_payment?,
      emburse: self.emburse?,
      expensify: self.expensify?,
      for_invoice: self.for_invoice?
    }
  end

  def emburse?
    filter_for 'emburse'
  end

  def expensify?
    filter_for 'expensify'
  end

  def for_invoice?
    filter_for 'event transfer'
  end

  # is this a potential invoice payout transaction?
  def potential_payout?
    self.amount > 0
  end

  def potential_fee_reimbursement?
    self.name.include?('FEE REFUND') || self.name.include?('FEE REIMBURSEMENT')
  end

  def potential_fee_payment?
    self.name.include?('Bank Fee')
  end

  def ensure_paired_correctly
    # NOTE: here, we have to compare to fee_relationship&.event and not just event,
    # because fee_relationship is the attribute directly set by a request to update
    # and reflects the most up-to-date value of event, and just "event" is a getter
    # that may be cached for the model and thus incorrect.

    # if linked to an invoice, check that invoice's event is transaction's event
    if !invoice_payout.nil? && invoice_payout.invoice && invoice_payout.invoice.event != fee_relationship&.event
      # NOTE: this extra check ^^^^^^^^^^^^^^^^^^^^^^ is to not break with historical data that
      # no longer correctly conforms to correct schema. (InvoicePayout without Invoice) (TX ID 5467)
      errors.add(:base, "Paired invoice payout's event must match transaction's event")
    end

    # if LCR linked, check that LCR's event is transaction's event
    if !load_card_request.nil? && load_card_request.event != fee_relationship&.event
      errors.add(:base, "Paired load card request's event must match transaction's event")
      return 3
    end
  end

  private

  def slug_text
    "#{date} #{name}"
  end

  def filter_for(text)
    name&.downcase&.include? text
  end

end
