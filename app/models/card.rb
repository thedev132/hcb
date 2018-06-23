class Card < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :event
  has_one :card_request

  validates :last_four, :full_name, :address, :expiration_month, :expiration_year, presence: true
  validates :last_four, numericality: { only_integer: true }
  validates :expiration_year, numericality: { only_integer: true, less_than_or_equal_to: 11, greater_than_or_equal_to: 0 }
end
