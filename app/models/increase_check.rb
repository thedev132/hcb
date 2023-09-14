# frozen_string_literal: true

# == Schema Information
#
# Table name: increase_checks
#
#  id              :bigint           not null, primary key
#  aasm_state      :string
#  address_city    :string
#  address_line1   :string
#  address_line2   :string
#  address_state   :string
#  address_zip     :string
#  amount          :integer
#  approved_at     :datetime
#  increase_state  :string
#  increase_status :string
#  memo            :string
#  payment_for     :string
#  recipient_name  :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  event_id        :bigint           not null
#  increase_id     :string
#  user_id         :bigint
#
# Indexes
#
#  index_increase_checks_on_event_id  (event_id)
#  index_increase_checks_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class IncreaseCheck < ApplicationRecord
  include AASM

  belongs_to :event
  belongs_to :user, optional: true

  has_one :canonical_pending_transaction
  has_one :grant, required: false

  after_create do
    create_canonical_pending_transaction!(event:, amount_cents: -amount, memo: "OUTGOING CHECK", date: created_at)
  end

  aasm timestamps: true, whiny_persistence: true do
    state :pending, initial: true
    state :approved
    state :rejected

    event :mark_approved do
      transitions from: :pending, to: :approved
    end

    event :mark_rejected do
      after do
        canonical_pending_transaction.decline!
      end
      transitions from: :pending, to: :rejected
    end
  end

  validates :amount, numericality: { greater_than: 0, message: "can't be zero!" }
  validates :memo, length: { in: 1..73 }
  validates :recipient_name, length: { in: 1..250 }
  validates_presence_of :memo, :payment_for, :recipient_name, :address_line1, :address_city, :address_state, :address_zip
  validates :address_state, inclusion: { in: ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"], message: "This isn't a valid US state abbreviation!" }
  validates :address_zip, format: { with: /\A\d{5}(?:[-\s]\d{4})?\z/, message: "This isn't a valid ZIP code." }

  validate on: :create do
    if amount > event.balance_available_v2_cents
      errors.add(:amount, "You don't have enough money to send this check! Your balance is #{(event.balance_available_v2_cents / 100).to_money.format}.")
    end
  end

  scope :in_transit, -> { where(increase_status: [:pending_submission, :submitting, :submitted, :pending_mailing, :mailed]) }
  scope :canceled, -> { where(increase_status: [:rejected, :canceled, :stopped, :returned, :rejected]).or(where(aasm_state: :rejected)) }

  enum :increase_status, {
    pending_approval: "pending_approval",
    pending_submission: "pending_submission",
    submitting: "submitting",
    submitted: "submitted",
    pending_mailing: "pending_mailing",
    mailed: "mailed",
    canceled: "canceled",
    deposited: "deposited",
    stopped: "stopped",
    returned: "returned",
    rejected: "rejected",
    requires_attention: "requires_attention"
  }, prefix: :increase

  def state
    if pending?
      :muted
    elsif rejected? || increase_canceled? || increase_stopped? || increase_returned? || increase_rejected?
      :error
    elsif increase_deposited?
      :success
    else
      :info
    end
  end

  def state_text
    if pending?
      "Pending approval"
    elsif rejected?
      "Rejected"
    elsif increase_pending_submission? || increase_submitting? || increase_submitted? || increase_pending_mailing?
      "Processing"
    elsif increase_mailed?
      "On the way"
    elsif increase_deposited?
      "Deposited"
    elsif increase_canceled? || increase_stopped?
      "Canceled"
    elsif increase_returned?
      "Returned"
    end
  end

  alias_attribute :name, :recipient_name

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::INCREASE_CHECK_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
  end

  def sent?
    approved?
  end

  def address
    "#{address_line1} #{address_line2} - #{address_city}, #{address_state} #{address_zip}"
  end

  def send_check!
    return unless may_mark_approved?

    increase_check = Increase::CheckTransfers.create(
      account_id: IncreaseService::AccountIds::FS_MAIN,
      address_city:,
      address_line1:,
      address_line2: address_line2.presence,
      address_state:,
      address_zip:,
      amount:,
      message: memo,
      recipient_name:,
    )

    update!(increase_id: increase_check["id"], increase_status: increase_check["status"])

    mark_approved!

    if grant.present?
      grant.mark_fulfilled!
    end
  end

end
