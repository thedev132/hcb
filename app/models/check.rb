class Check < ApplicationRecord
  include Commentable

  belongs_to :creator, class_name: 'User'
  belongs_to :lob_address, required: true

  accepts_nested_attributes_for :lob_address

  has_many :t_transactions, class_name: 'Transaction', inverse_of: :check

  before_create :default_values

  validates_length_of :transaction_memo, maximum: 30
  validates_uniqueness_of :transaction_memo

  validate :transaction_amount

  scope :pending, -> { where(approved_at: nil, rejected_at: nil, voided_at: nil) }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }

  # Syncing with Lob
  before_save :create_lob_check

  before_update :updatable?
  before_destroy :destroyable?

  def set_fields_from_lob_check(check)
    self.description = check['description']
    self.memo = check['memo']
    self.amount = BigDecimal(check['amount'].to_s) * 100
    self.check_number = check['check_number']
    self.expected_delivery_date = check['expected_delivery_date']
    self.send_date = check['send_date']
    self.lob_id = check['id']
  end

  def status
    if refunded?
      :refunded
    elsif voided?
      :voided
    elsif pending_void?
      :pending_void
    elsif deposited?
      :deposited
    elsif approved?
      :in_transit
    elsif rejected?
      :rejected
    else
      :pending
    end
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

  def self.deposited
    select { |check| check.deposited? }
  end

  def self.in_transit
    select { |check| check.in_transit? }
  end

  def self.unfinished_void
    select { |check| check.unfinished_void? }
  end

  def self.refunded_but_needs_match
    select { |check| check.refunded_at.present? && check.t_transactions.size != 4 }
  end

  def pending?
    approved_at.nil?
  end

  def approved?
    approved_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  # A check is in transit if it's been approved & hasn't been voided
  def in_transit?
    approved? && !voided? && !pending_void? && !deposited?
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
    #if update(approved_at: DateTime.now)
      #RefundSentCheckJob.set(wait_until: send_date + 1.month).perform_later(self)
      #return true
    #end
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

  def default_values
    self.description = "#{event.name} - #{lob_address.name}"[0..255]
    self.transaction_memo = "PENDING-#{SecureRandom.hex(6)}"[0..30]
    self.exported_at = nil
  end

  def transaction_amount
    self.t_transactions.each do |t|
      unless t.amount.abs == self.amount.abs
        errors.add :t_transactions, "Check and transaction amount don't match"
      end
    end
  end

  def create_lob_check
    return unless approved_at_was.nil? && !approved_at.nil?

    lob_check = LobService.instance.create_check(
      description,
      memo[0..40],
      lob_address.lob_id,
      amount.to_f / 100,
      "This check was sent by The Hack Foundation on behalf of #{event.name}. #{event.name} is fiscally sponsored by the Hack Foundation (d.b.a Hack Club), a 501(c)(3) nonprofit with the EIN 81-2908499"
    )

    set_fields_from_lob_check(lob_check)
    self.transaction_memo = "#{check_number} Check"[0..30]
  end

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
