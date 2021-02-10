class Check < ApplicationRecord
  include AASM
  include Commentable

  belongs_to :creator, class_name: 'User'
  belongs_to :lob_address, required: true

  accepts_nested_attributes_for :lob_address

  has_many :t_transactions, class_name: 'Transaction', inverse_of: :check

  validates :send_date, presence: true
  validate :send_date_must_be_in_future

  aasm do
    state :created, initial: true
    state :in_transit
    state :deposited
    state :voided
    state :refunded

    state :rejected # deprecate
    state :approved # deprecate
    state :pending # deprecate
    state :pending_void # deprecate

    event :mark_in_transit do
      transitions to: :in_transit
    end
    
    event :mark_deposited do
      transitions to: :deposited
    end
 
    event :mark_refunded do
      transitions to: :refunded
    end

    event :mark_voided do
      transitions to: :voided
    end
  end

  def event
    lob_address.event
  end

  def status
    aasm_state.to_sym
  end

  def status_text
    aasm_state
  end

  def status_text_long
    aasm_state
  end

  def state
    aasm_state
  end

  def self.refunded_but_needs_match
    select { |check| check.refunded_at.present? && check.t_transactions.size != 4 }
  end

  # Can be ready to refund
  def pending_void?
    approved? && voided_at.present? && !deposited? && !voided?
  end

  # Ready to be refunded
  def unfinished_void?
    !refunded_at.present? && voided_at && voided_at + 1.day < DateTime.now && !deposited?
  end

  # Refunded & needs refund transactions attached
  def refunded_but_needs_match?
    refunded_at.present? && t_transactions != 4
  end

  # Void requested & check deposited before it could go through
  def failed_void?
    approved? && voided_at.present? && t_transactions.size == 3 && t_transactions.sum(&:amount) < 0
  end

  def state_icon
    'checkmark' if deposited?
  end

  def admin_dropdown_description
    "#{check_number.present? ? check_number : 'No number'} | #{event.name} | #{lob_address.name} | #{status} - #{ApplicationController.helpers.render_money amount}"
  end

  def voidable?
    !deposited? && !pending_void? && !voided? && !rejected?
  end

  def sent?
    send_date ? send_date.past? : false
  end

  def refund!
    unless refunded_at.nil?
      errors.add(:check, 'has already been refunded')
      return self
    end

    if pending_void? || voided?
      return update(refunded_at: DateTime.now)
    else
      errors.add(:check, 'needs to be voided first')
      return self
    end
  end

  def url
    # lob URLs expire after 30 days https://lob.com/docs/ruby#urls
    # so we'll regenerate this whenever we need it

    @lob_check_url ||= begin
      lob_check = LobService.instance.client.checks.find(self.lob_id)

      lob_check["url"]
    end

    @lob_check_url
  end

  private

  def send_date_must_be_in_future
    self.errors.add(:send_date, "must be at least 24 hours in the future") if send_date.nil? || send_date <= (Time.now.utc + 24.hours)
  end
end
