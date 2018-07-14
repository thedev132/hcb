class Transaction < ApplicationRecord
  acts_as_paranoid

  default_scope { order(date: :desc, id: :desc) }

  belongs_to :bank_account

  belongs_to :fee_relationship, inverse_of: :t_transaction, required: false
  has_one :event, through: :fee_relationship

  belongs_to :load_card_request, inverse_of: :t_transaction

  has_many :comments, as: :commentable

  accepts_nested_attributes_for :fee_relationship

  validates :is_event_related, inclusion: { in: [ true, false ] }

  validates :fee_relationship,
    absence: true,
    unless: -> { self.is_event_related }

  after_initialize :default_values
  after_create :notify_admin

  def default_values
    self.is_event_related = true if self.is_event_related.nil?

  end

  def notify_admin
    TransactionMailer.with(transaction: self).notify_admin.deliver_later
  end

  def fee
    is_event_related && fee_relationship
  end

  def emburse?
    name.include? 'emburse'
  end
end
