class Transaction < ApplicationRecord
  default_scope { order(date: :desc) }

  belongs_to :bank_account
  belongs_to :fee_relationship, inverse_of: :t_transaction
  has_one :event, through: :fee_relationship

  accepts_nested_attributes_for :fee_relationship

  after_initialize :init_fee_relationship

  def init_fee_relationship
    return if self.fee_relationship

    self.fee_relationship = FeeRelationship.new
  end
end
