class Card < ApplicationRecord
  extend FriendlyId

  scope :deactivated, -> { where.not(deactivated_at: nil) }
  scope :active, -> { where(deactivated_at: nil) }

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

  before_save :sync_with_emburse

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

  # Emburse cards have three activation states:
  # 1. "unactivated", when card first ships. Must be activated by user
  #   at emburse.com/activate to be active, cannot be activated by Bank
  # 2. "active", active card
  # 3. "suspended", deactivated by user and can be activated again thru Bank.
  def status_text
    if requires_activation?
      'Awaiting activation'
    elsif active?
      'Active'
    else
      'Deactivated'
    end
  end
      
  def deactivate!
    self.deactivated_at = DateTime.now
    self.save
  end

  def reactivate!
    self.deactivated_at = nil
    self.save
  end

  def requires_activation?
    emburse_obj[:state] == 'unactivated'
  end

  def active?
    emburse_obj[:state] == 'active'
  end

  def suspended?
    emburse_obj[:state] == 'suspended'
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

  def sync_with_emburse
    if self.deactivated_at_changed?
      if emburse_obj[:state] != 'active' && emburse_obj[:state] != 'suspended'
        errors.add(:card, 'cannot be deactivated until it is first activated')
        return
      end

      if self.deactivated_at.nil?
        ::EmburseClient::Card.update(self.emburse_id, state: 'active')
      else
        ::EmburseClient::Card.update(self.emburse_id, state: 'suspended')
      end
    end
  end

  def slug_text
    "#{self.full_name} #{self.last_four}"
  end
end
