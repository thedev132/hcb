class Card < ApplicationRecord
  extend FriendlyId

  paginates_per 100

  friendly_id :slug_text, use: :slugged

  belongs_to :user
  belongs_to :event
  has_one :card_request
  has_many :load_card_requests
  has_many :emburse_transactions

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

  def amount_spent
    obj = emburse_obj
    return (obj[:allowance][:balance].to_f * 100).round(2) if obj

    nil
  end

  def department_id
    emburse_obj&.department&.id
  end

  private

  def emburse_obj
    ::EmburseClient::Card.get(self.emburse_id)
  end

  def emburse_id_format
    emburse_id_regex = /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
    unless emburse_id_regex.match? emburse_id
      errors.add(:emburse_id, "is incorrectly formatted")
    end
  end

  def slug_text
    "#{self.full_name} #{self.last_four}"
  end
end
