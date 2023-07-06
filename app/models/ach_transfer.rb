# frozen_string_literal: true

# == Schema Information
#
# Table name: ach_transfers
#
#  id                        :bigint           not null, primary key
#  aasm_state                :string
#  account_number_ciphertext :text
#  amount                    :integer
#  approved_at               :datetime
#  bank_name                 :string
#  confirmation_number       :text
#  payment_for               :text
#  recipient_name            :string
#  recipient_tel             :string
#  rejected_at               :datetime
#  routing_number            :string
#  scheduled_arrival_date    :datetime
#  scheduled_on              :date
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  creator_id                :bigint
#  event_id                  :bigint
#  increase_id               :text
#  processor_id              :bigint
#
# Indexes
#
#  index_ach_transfers_on_creator_id    (creator_id)
#  index_ach_transfers_on_event_id      (event_id)
#  index_ach_transfers_on_increase_id   (increase_id) UNIQUE
#  index_ach_transfers_on_processor_id  (processor_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (event_id => events.id)
#
class AchTransfer < ApplicationRecord
  has_paper_trail skip: [:account_number] # ciphertext columns will still be tracked
  has_encrypted :account_number

  include PublicIdentifiable
  set_public_id_prefix :ach

  include AASM
  include Commentable

  include PgSearch::Model
  pg_search_scope :search_recipient, against: [:recipient_name], using: { tsearch: { prefix: true, dictionary: "english" } }, ranked_by: "ach_transfers.created_at"

  belongs_to :creator, class_name: "User", optional: true
  belongs_to :processor, class_name: "User", optional: true
  belongs_to :event

  validates :amount, numericality: { greater_than: 0, message: "must be greater than 0" }
  validates_length_of :routing_number, is: 9
  validate :scheduled_on_must_be_in_the_future, on: :create

  has_one :t_transaction, class_name: "Transaction", inverse_of: :ach_transfer
  has_one :grant, required: false
  has_one :raw_pending_outgoing_ach_transaction, foreign_key: :ach_transaction_id
  has_one :canonical_pending_transaction, through: :raw_pending_outgoing_ach_transaction

  scope :scheduled_for_today, -> { scheduled.where(scheduled_on: ..Date.today) }

  aasm whiny_persistence: true do
    state :pending, initial: true
    state :scheduled
    state :in_transit
    state :rejected
    state :failed
    state :deposited

    event :mark_in_transit do
      transitions from: [:pending, :deposited, :scheduled], to: :in_transit
    end

    event :mark_rejected do
      after do
        canonical_pending_transaction.decline!
      end
      transitions from: [:pending, :scheduled], to: :rejected
    end

    event :mark_deposited do
      transitions from: :in_transit, to: :deposited
    end

    event :mark_scheduled do
      transitions from: :pending, to: :scheduled
    end
  end

  # Eagerly create HcbCode object
  after_create :local_hcb_code

  def send_ach_transfer!
    return unless may_mark_in_transit?

    increase_ach_transfer = Increase::AchTransfers.create(
      account_id: event.increase_account_id,
      account_number:,
      routing_number:,
      amount:,
      statement_descriptor: payment_for,
      individual_name: recipient_name[0...22],
      company_name: event.name[0...16]
    )

    update!(increase_id: increase_ach_transfer["id"])
    mark_in_transit!
  end

  def status
    aasm.current_state
  end

  alias_attribute :name, :recipient_name

  def status_text
    aasm.human_state
  end

  alias_method :state_text, :status_text

  def status_text_long
    case status
    when :deposited then "Deposited successfully"
    when :scheduled then "Scheduled for #{scheduled_on.strftime("%B %-d, %Y")}"
    when :in_transit then "In transit"
    when :pending then "Waiting on Bank approval"
    when :rejected then "Rejected"
    end
  end

  def state
    case status
    when :deposited then :success
    when :in_transit then :info
    when :scheduled then :pending
    when :pending then :pending
    when :rejected then :error
    end
  end

  def state_icon
    "checkmark" if deposited?
  end

  def approved?
    !pending?
  end

  def admin_dropdown_description
    "#{event.name} - #{recipient_name} | #{ApplicationController.helpers.render_money amount}"
  end

  def smart_memo
    recipient_name.to_s.upcase
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(hcb_code:)
  end

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::ACH_TRANSFER_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
  end

  private

  def scheduled_on_must_be_in_the_future
    if scheduled_on.present? && scheduled_on.before?(Date.today)
      errors.add(:scheduled_on, "must be in the future")
    end
  end

end
