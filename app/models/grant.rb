# frozen_string_literal: true

# == Schema Information
#
# Table name: grants
#
#  id                     :bigint           not null, primary key
#  aasm_state             :string
#  amount_cents           :integer
#  ends_at                :datetime
#  reason                 :text
#  receipt_method         :integer
#  recipient_name         :string
#  recipient_organization :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ach_transfer_id        :bigint
#  disbursement_id        :bigint
#  event_id               :bigint           not null
#  increase_check_id      :bigint
#  processed_by_id        :bigint
#  recipient_id           :bigint           not null
#  submitted_by_id        :bigint           not null
#
# Indexes
#
#  index_grants_on_ach_transfer_id    (ach_transfer_id)
#  index_grants_on_disbursement_id    (disbursement_id)
#  index_grants_on_event_id           (event_id)
#  index_grants_on_increase_check_id  (increase_check_id)
#  index_grants_on_processed_by_id    (processed_by_id)
#  index_grants_on_recipient_id       (recipient_id)
#  index_grants_on_submitted_by_id    (submitted_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (processed_by_id => users.id)
#  fk_rails_...  (submitted_by_id => users.id)
#
class Grant < ApplicationRecord
  include AASM
  include Hashid::Rails

  has_paper_trail

  attr_accessor :email

  belongs_to :event
  belongs_to :submitted_by, class_name: "User"
  belongs_to :recipient, class_name: "User", optional: true
  belongs_to :processed_by, class_name: "User", optional: true

  has_one :canonical_pending_transaction, required: false

  monetize :amount_cents

  before_create :create_user

  after_create do
    create_canonical_pending_transaction!(event:, amount_cents: -amount_cents, memo: "OUTGOING GRANT", date: created_at)
  end

  validates_presence_of :email, on: :create, unless: :recipient
  validates_presence_of :reason, :amount_cents

  enum :receipt_method, [:new_organization, :ach_transfer, :check], prefix: "receipt_method"

  belongs_to :disbursement, optional: true
  belongs_to :ach_transfer, optional: true
  belongs_to :increase_check, optional: true

  aasm timestamps: true, whiny_persistence: true do
    state :pending, initial: true, display: "Pending approval"
    state :additional_info_needed
    state :rejected
    state :waiting_on_recipient
    state :verifying
    state :fulfilled, display: "Sent"

    event :mark_approved do
      after do
        GrantMailer.with(grant: self).invitation.deliver_later
        GrantMailer.with(grant: self).approved.deliver_later
      end
      transitions from: [:pending, :additional_info_needed], to: :waiting_on_recipient
    end

    event :mark_additional_info_needed do
      transitions from: :pending, to: :additional_info_needed
    end

    event :mark_rejected do
      after do
        canonical_pending_transaction.decline!
      end
      transitions from: [:pending, :additional_info_needed, :waiting_on_recipient, :verifying], to: :rejected
    end

    event :mark_verifying do
      transitions from: :waiting_on_recipient, to: :verifying
    end

    event :mark_fulfilled do
      transitions from: [:waiting_on_recipient, :verifying], to: :fulfilled
    end
  end

  def recipient_name
    recipient&.name || super
  end

  def state_text
    aasm.human_state
  end

  def status_badge_color
    if rejected?
      :error
    elsif additional_info_needed?
      :info
    elsif waiting_on_recipient?
      :muted
    elsif fulfilled?
      :success
    else
      :muted
    end
  end

  private

  def create_user
    self.recipient ||= User.find_or_create_by!(email: self.email)
  end

end
