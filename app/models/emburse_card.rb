# frozen_string_literal: true

class EmburseCard < ApplicationRecord
  extend FriendlyId

  scope :deactivated, -> { where.not(emburse_state: "active") }
  scope :active, -> { where(deactivated_at: nil, emburse_state: "active") }

  paginates_per 100

  friendly_id :slug_text, use: :slugged

  belongs_to :user
  belongs_to :event
  has_one :emburse_card_request
  has_many :emburse_transfers
  has_many :emburse_transactions
  has_many :transactions_missing_receipts, -> { awaiting_receipt }, foreign_key: :emburse_card_id, class_name: "EmburseTransaction"

  # general validations
  validates :full_name,
            :expiration_month,
            :expiration_year,
            :emburse_id,
            presence: true

  # validations for physical
  validates :last_four,
            :address,
            presence: true
  validates :last_four, numericality: { only_integer: true }

  validates :expiration_month, numericality: {
    only_integer: true,
    less_than_or_equal_to: 12,
    greater_than_or_equal_to: 1
  }
  validates :expiration_year, numericality: { only_integer: true }
  validate :emburse_id_format

  after_save :sync_to_emburse!
  before_validation :sync_from_emburse!, unless: :persisted?

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

  def suspected_subscriptions
    emburse_transactions.group(:merchant_name).having("COUNT(*)>3").count.keys
  end

  # Emburse emburse_cards have three activation states:
  # 1. "unactivated", when emburse_card first ships. Must be activated by user
  #   at emburse.com/activate to be active, cannot be activated by Bank
  # 2. "active", active emburse_card
  # 3. "suspended", deactivated by user and can be activated again thru Bank.
  def status_text
    if requires_activation?
      "Shipping"
    elsif active?
      "Active"
    elsif suspended?
      "Suspended"
    elsif canceled?
      "Canceled"
    end
  end

  def formatted_card_number
    "•••• •••• •••• #{last_four}"
  end

  def hidden_card_number
    "•••• •••• •••• ••••"
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
    sync_from_emburse! && self.save if self.emburse_state.blank?
    self.emburse_state == "unactivated"
  end

  def active?
    sync_from_emburse! && self.save if self.emburse_state.blank?
    self.emburse_state == "active"
  end

  def suspended?
    sync_from_emburse! && self.save if self.emburse_state.blank?
    self.emburse_state == "suspended"
  end

  def canceled?
    sync_from_emburse! && self.save if self.emburse_state.blank?
    self.emburse_state == "terminated"
  end

  def sync_from_emburse!
    self.is_virtual = emburse_obj[:is_virtual]

    expiration = Date.parse(emburse_obj[:expiration])
    self.expiration_month = expiration.month
    self.expiration_year = expiration.year.to_s[-2..-1].to_i

    self.emburse_state = emburse_obj[:state]

    self.last_four = emburse_obj[:last_four]

    first_name = emburse_obj[:assigned_to][:first_name]
    last_name = emburse_obj[:assigned_to][:last_name]
    self.full_name = "#{first_name} #{last_name}"

    if emburse_obj[:shipping_address]
      sa = emburse_obj[:shipping_address]
      address = []
      address << sa[:attn]
      address << sa[:address_1]
      address << sa[:address_2] unless sa[:address_2].blank?
      address << "#{sa[:city]}, #{sa[:state]} #{sa[:zip_code]}"

      self.address = address.join("/n").strip
    end
  end

  private

  def emburse_obj
    @emburse_obj ||= ::EmburseClient::Card.get(self.emburse_id)
    @emburse_obj
  end

  def emburse_id_format
    emburse_id_regex = /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
    unless emburse_id_regex.match? emburse_id
      errors.add(:emburse_id, "is incorrectly formatted")
    end
  end

  def sync_to_emburse!
    if self.deactivated_at_changed?
      if emburse_obj[:state] == "unactive"
        errors.add(:emburse_card, "cannot be deactivated until it is first activated")
        return
      end

      if self.deactivated_at.nil?
        ::EmburseClient::Card.update(self.emburse_id, state: "active")
      else
        ::EmburseClient::Card.update(self.emburse_id, state: "suspended")
      end
    end
  end

  def slug_text
    "#{self.full_name} #{self.last_four}"
  end
end
