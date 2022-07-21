# frozen_string_literal: true

# == Schema Information
#
# Table name: disbursements
#
#  id              :bigint           not null, primary key
#  amount          :integer
#  errored_at      :datetime
#  fulfilled_at    :datetime
#  name            :string
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

  # Disbursement goes through 5 stages:
  # 1. Reviewing (before human review)
  # 2. Pending (before automated job tries to process the transfer)
  # 3. Processing
  # 4. Fulfilled
  # or, if not accepted...
  # 5. Rejected
  scope :reviewing, -> { where(fulfilled_at: nil, errored_at: nil, rejected_at: nil, fulfilled_by_id: nil).where.not(requested_by_id: nil) }
  scope :pending, -> {   where(fulfilled_at: nil, errored_at: nil, rejected_at: nil).where.not(fulfilled_by_id: nil) }
  scope :processing, -> { where.not(fulfilled_at: nil).reject { |d| d.fulfilled? } }
  scope :fulfilled, -> { where.not(fulfilled_at: nil).select { |d| d.fulfilled? } }
  scope :rejected, -> { where.not(rejected_at: nil) }
  scope :errored, -> { where.not(errored_at: nil) }

  scope :reviewing_or_processing, -> { where(fulfilled_at: nil, rejected_at: nil, errored_at: nil).where.not(fulfilled_by_id: nil) }

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

  def reviewing?
    !requested_by.nil? && !processed? && !rejected? && !errored? && fulfilled_by.nil?
  end

  def pending?
    !reviewing? && !processed? && !rejected? && !errored?
  end

  def processed?
    fulfilled_by.present?
  end

  def fulfilled?
    # two transactions, one coming out of source event and another
    # going into destination event
    canonical_transactions.size == 2
  end

  def rejected?
    rejected_at.present?
  end

  def errored?
    errored_at.present?
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
    elsif processed?
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
    elsif processed?
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

  def mark_fulfilled!
    update(fulfilled_at: DateTime.now)
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

end
