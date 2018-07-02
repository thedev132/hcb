class Card < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_one :card_request
  has_many :load_card_requests

  validates :last_four,
            :full_name,
            :address,
            :expiration_month,
            :expiration_year,
            :emburse_id,
            presence: true
  validates :last_four, numericality: { only_integer: true }
  validates :expiration_month, numericality: {
    only_integer: true,
    less_than_or_equal_to: 12,
    greater_than_or_equal_to: 1
  }
  validates :expiration_year, numericality: { only_integer: true }
  validate :emburse_id_format

  def emburse_path
    "https://app.emburse.com/cards/#{emburse_id}"
  end

  private

  def emburse_id_format
    emburse_id_regex = /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
    unless emburse_id_regex.match? emburse_id
      errors.add(:emburse_id, "is incorrectly formatted")
    end
  end
end
