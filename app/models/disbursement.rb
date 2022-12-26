# frozen_string_literal: true

# == Schema Information
#
# Table name: disbursements
#
#  id              :bigint           not null, primary key
#  aasm_state      :string
#  amount          :integer
#  deposited_at    :datetime
#  errored_at      :datetime
#  fulfilled_at    :datetime
#  in_transit_at   :datetime
#  name            :string
#  pending_at      :datetime
#  rejected_at     :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  event_id        :bigint
#  fulfilled_by_id :bigint
#  requested_by_id :bigint
#  source_event_id :bigint
#
# Indexes
#
#  index_disbursements_on_event_id         (event_id)
#  index_disbursements_on_fulfilled_by_id  (fulfilled_by_id)
#  index_disbursements_on_requested_by_id  (requested_by_id)
#  index_disbursements_on_source_event_id  (source_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (fulfilled_by_id => users.id)
#  fk_rails_...  (requested_by_id => users.id)
#  fk_rails_...  (source_event_id => events.id)
#
class Disbursement < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_name, against: [:name]

  include AASM
  include Commentable

  has_paper_trail

  include PublicIdentifiable
  set_public_id_prefix :xfr # Transfer

  belongs_to :fulfilled_by, class_name: "User", optional: true
  belongs_to :requested_by, class_name: "User", optional: true

  belongs_to :destination_event, foreign_key: 'event_id', class_name: "Event", inverse_of: 'incoming_disbursements'
  belongs_to :source_event, class_name: "Event", inverse_of: 'outgoing_disbursements'
  belongs_to :event

  has_one :raw_pending_incoming_disbursement_transaction
  has_one :raw_pending_outgoing_disbursement_transaction

  has_many :t_transactions, class_name: "Transaction", inverse_of: :disbursement

  validates_presence_of :source_event_id,
                        :event_id,
                        :amount,
                        :name

  validates :amount, numericality: { greater_than: 0 }
  validate :events_are_different
  validate :events_are_not_demos

  scope :processing, -> { in_transit }
  scope :fulfilled, -> { deposited }
  scope :reviewing_or_processing, -> { where(aasm_state: [:reviewing, :pending, :in_transit]) }

  aasm timestamps: true do
    state :reviewing, initial: true # Being reviewed by an admin
    state :pending                  # Waiting to be processed by the TX engine
    state :in_transit               # Transfer started on SVB
    state :deposited                # Transfer completed!
    state :rejected                 # Rejected by admin
    state :errored                  # oh no! an error!

    event :mark_approved do
      after do |fulfilled_by|
        update(fulfilled_by: fulfilled_by)
      end
      transitions from: :reviewing, to: :pending
    end

    event :mark_in_transit do
      transitions from: :pending, to: :in_transit
    end

    event :mark_deposited do
      transitions from: :in_transit, to: :deposited
    end

    event :mark_errored do
      transitions from: [:pending, :in_transit], to: :errored
    end

    event :mark_rejected do
      after do |fulfilled_by|
        update(fulfilled_by: fulfilled_by)
      end
      transitions from: [:reviewing, :pending], to: :rejected
    end
  end

  # Eagerly create HcbCode object
  after_create :local_hcb_code

  alias_attribute :approved_at, :pending_at

  # Returns the perceived time of the transfer to an event with fronting enabled
  def transferred_at
    # `approved_at` isn't set on some old disbursements, so fall back to `in_transit_at`.
    approved_at || in_transit_at
  end

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::DISBURSEMENT_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(hcb_code: hcb_code)
  end

  def canonical_pending_transactions
    @canonical_pending_transactions ||= ::CanonicalPendingTransaction.where(hcb_code: hcb_code)
  end

  def processed?
    in_transit? || deposited?
  end

  def fulfilled?
    deposited?
  end

  def filter_data
    {
      exists: true,
      reviewing: reviewing?,
      pending: pending?,
      processing: processed? && !fulfilled?,
      fulfilled: fulfilled?,
      rejected: rejected?,
    }
  end

  def status
    state
  end

  def state
    if fulfilled?
      :success
    elsif processed? || pending?
      if destination_event.can_front_balance?
        :success
      else
        :info
      end
    elsif rejected?
      :error
    elsif errored?
      :error
    elsif reviewing?
      :reviewing
    else
      :pending
    end
  end

  def v3_api_state
    state_text.underscore
  end

  def state_text
    if fulfilled?
      "fulfilled"
    elsif processed? || pending?
      if destination_event.can_front_balance?
        "fulfilled"
      else
        "processing"
      end
    elsif rejected?
      "rejected"
    elsif errored?
      "errored"
    elsif reviewing?
      "under review"
    else
      "pending"
    end
  end

  def state_icon
    "checkmark" if fulfilled? || processed? || (pending? && destination_event.can_front_balance?)
  end

  def admin_dropdown_description
    "#{ApplicationController.helpers.render_money amount} for #{name} to #{event.name}"
  end

  def transaction_memo
    "HCB DISBURSE #{id}"
  end

  private

  def events_are_different
    self.errors.add(:event, "must be different than source event") if event_id == source_event_id
  end

  def events_are_not_demos
    self.errors.add(:event, "cannot be a demo event") if event.demo_mode?
    self.errors.add(:source_event, "cannot be a demo event") if source_event.demo_mode?
  end

end
