class Check < ApplicationRecord
  include AASM
  include Commentable

  belongs_to :creator, class_name: 'User'
  belongs_to :lob_address, required: true

  accepts_nested_attributes_for :lob_address

  has_many :t_transactions, class_name: 'Transaction', inverse_of: :check

  aasm do
    state :approved # deprecate
    state :pending # deprecate
    state :pending_void # deprecate
    state :in_transit, initial: true
    state :voided
    state :refunded
    state :deposited
    state :rejected

    event :mark_pending do
      transitions to: :pending
    end

    event :mark_refunded do
      transitions to: :refunded
    end

    event :mark_voided do
      transitions to: :voided
    end

    event :mark_deposited do
      transitions to: :deposited
    end

    event :mark_in_transit do
      transitions to: :in_transit
    end

    event :mark_rejected do
      transitions to: :rejected
    end
  end

  before_update :updatable?
  before_destroy :destroyable?

  def status
    aasm_state.to_sym
  end

  def status_text
    case status
    when :refunded then 'Refunded'
    when :voided then 'Voided'
    when :pending_void then 'Pending void'
    when :deposited then 'Deposited'
    when :in_transit then 'In transit'
    when :rejected then 'Rejected'
    when :pending then 'Pending approval'
    end
  end

  def status_text_long
    case status
    when :refunded then 'Refunded'
    when :voided then 'Voided'
    when :pending_void then 'Attempting to void'
    when :deposited then 'Deposited successfully'
    when :in_transit then 'In transit'
    when :rejected then 'Rejected by Hack Club Bank staff'
    when :pending then 'Waiting approval from Hack Club Bank staff'
    end
  end

  def state
    case status
    when :refunded then :info
    when :voided then :error
    when :pending_void then :error
    when :deposited then :success
    when :in_transit then :info
    when :rejected then :error
    when :pending then :pending
    end
  end

  def self.unfinished_void
    select { |check| check.unfinished_void? }
  end

  def self.refunded_but_needs_match
    select { |check| check.refunded_at.present? && check.t_transactions.size != 4 }
  end

  # if a void was put in and the sum of transaction is neutral (no money lost or gained)
  def voided?
    voided_at.present? && (
      approved? && t_transactions.size == 4 && t_transactions.sum(&:amount) == 0 ||
      !approved?
    )
  end

  # Deposited
  def deposited?
    approved_at && t_transactions.size == 3 && t_transactions.sum(&:amount) < 0 && !voided?
  end

  # Refunded (shown to user)
  def refunded?
    refunded_at.present? && voided?
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

  def exported?
    exported_at.present?
  end

  def event
    lob_address.event
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

  def approve!
    if approved_at != nil
      errors.add(:check, 'has already been approved!')
      return false
    end
    if update(approved_at: DateTime.now)
     #RefundSentCheckJob.set(wait_until: send_date + 1.month).perform_later(self) # TODO: move to nightly or monthly cron job for reliability
     return true
    end
    false
  end

  def reject!
    if rejectable? and update(rejected_at: DateTime.now)
      return true
    else
      errors.add(:check, 'is not able to be rejected!')
      return false
    end
  end

  def export!
    unless exported_at.nil?
      errors.add(:check, 'has already been exported!')
      return self
    end
    update(exported_at: DateTime.now)
  end

  def void!
    if voided_at != nil
      errors.add(:check, 'has already been voided!')
      return self
    end
    if voidable?
      return update(exported_at: nil, voided_at: DateTime.now) if approved?

      # if it hasn't been approved, no action required from Michael & no export needed
      return update(exported_at: DateTime.now, voided_at: DateTime.now) if !approved?
    else
      errors.add(:check, 'cannot be voided!')
      return self
    end
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

  def updatable?
    approved_at.nil?
  end

  def destroyable?
    approved_at.nil?
  end

  def rejectable?
    approved_at.nil?
  end
end
