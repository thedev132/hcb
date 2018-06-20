class Transaction < ApplicationRecord
  acts_as_paranoid

  default_scope { order(date: :desc, id: :desc) }

  belongs_to :bank_account

  belongs_to :fee_relationship, inverse_of: :t_transaction, required: false
  has_one :event, through: :fee_relationship, required: false

  accepts_nested_attributes_for :fee_relationship

  validates :fee_relationship, :event,
    presence: true,
    if: -> { self.is_event_related == true }
  validates :fee_relationship, :event,
    absence: true,
    if: -> { self.is_event_related == false }

  after_initialize :default_values

  def default_values
    self.is_event_related = true if self.is_event_related.nil?
  end
end
