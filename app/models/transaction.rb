class Transaction < ApplicationRecord
  acts_as_paranoid

  default_scope { order(date: :desc, id: :desc) }
  scope :uncategorized, -> { where(is_event_related: true, fee_relationship_id: nil) }

  belongs_to :bank_account

  belongs_to :fee_relationship, inverse_of: :t_transaction, required: false
  has_one :event, through: :fee_relationship

  belongs_to :load_card_request, inverse_of: :t_transaction, required: false
  belongs_to :invoice_payout, inverse_of: :t_transaction, required: false

  has_many :comments, as: :commentable

  accepts_nested_attributes_for :fee_relationship

  validates :plaid_id, uniqueness: true
  validates :is_event_related, inclusion: { in: [ true, false ] }

  validates :fee_relationship,
    absence: true,
    unless: -> { self.is_event_related }

  after_initialize :default_values
  after_create :notify_admin

  def self.total_volume
    self.sum('@amount')
  end

  def default_values
    self.is_event_related = true if self.is_event_related.nil?
  end

  def notify_admin
    TransactionMailer.with(transaction: self).notify_admin.deliver_later
  end

  # Utility method for getting the fee on the transaction if there is one. Used
  # in CSV export.
  def fee
    is_event_related && fee_relationship.fee_applies && fee_relationship.fee_amount
  end

  def fee_payment?
    is_event_related && fee_relationship.is_fee_payment
  end

  def fee_applies?
    is_event_related && fee_relationship.fee_applies
  end

  # Emburse adds the word "emburse" to bank transactions made. This is a
  # convenience method to see when the statement line was probably from
  # Emburse.
  def emburse?
    name.include? 'emburse'
  end

  # is this a potential invoice payout transaction?
  def potential_payout?
    self.amount > 0
  end
end
