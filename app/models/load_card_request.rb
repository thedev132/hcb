class LoadCardRequest < ApplicationRecord
  include Rejectable

  # NOTE(@msw) LCRs used to be on a per-card basis & we're keeping the
  # association for compatability with migrations
  belongs_to :card, required: false

  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :creator, class_name: 'User'
  has_one :t_transaction, class_name: 'Transaction'

  validate :status_accepted_canceled_or_rejected

  scope :under_review, -> { where(rejected_at: nil, canceled_at: nil, accepted_at: nil) }
  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :pending, -> do
    includes(:t_transaction)
      .accepted
      .where(
        emburse_transaction_id: nil,
        transactions: { id: nil }
      )
  end
  scope :completed, -> { accepted.where.not(id: pending) }

  def status
    return 'pending' if LoadCardRequest.pending.include?(self)
    return 'completed' if LoadCardRequest.completed.include?(self)
    return 'canceled' if canceled_at.present?
    return 'rejected' if rejected_at.present?
    'under review'
  end

  def status_badge_type
    s = status.to_sym
    return 'warning' if s == :pending
    return 'success' if s == :completed
    return 'muted' if s == :canceled
    return 'error' if s == :rejected
    'pending'
  end

  def under_review?
    rejected_at.nil? && canceled_at.nil? && accepted_at.nil?
  end

  include ApplicationHelper
  def description
    "#{self.id} (#{render_money self.load_amount}, #{time_ago_in_words self.created_at} ago, #{self.event.name})"
  end
end
