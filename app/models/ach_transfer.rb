class AchTransfer < ApplicationRecord
  include AASM
  include Commentable

  belongs_to :creator, class_name: 'User'
  belongs_to :event

  validates_length_of :routing_number, is: 9

  has_one :t_transaction, class_name: 'Transaction', inverse_of: :ach_transfer

  scope :approved, -> { where.not(approved_at: nil) }

  aasm do
    state :pending, initial: true
    state :in_transit
    state :rejected
    state :deposited

    event :mark_in_transit do
      transitions from: :pending, to: :in_transit
    end

    event :mark_rejected do
      transitions from: :pending, to: :rejected
    end

    event :mark_deposited do
      transitions from: :in_transit, to: :deposited
    end
  end

  scope :pending_deprecated, -> { where(approved_at: nil, rejected_at: nil) }
  def self.in_transit_deprecated
    select { |a| a.approved_at.present? && a.t_transaction.nil? }
  end
  scope :rejected_deprecated, -> { where.not(rejected_at: nil) }
  def self.delivered
    select { |a| a.t_transaction.present? }
  end

  def status
    aasm_state.to_sym
  end

  def status_deprecated
    if t_transaction
      :deposited
    elsif approved_at
      :in_transit
    elsif rejected_at
      :rejected
    elsif pending?
      :pending
    end
  end

  def status_text
    status.to_s.humanize
  end

  def status_text_long
    case status
    when :deposited then 'Deposited successfully'
    when :in_transit then 'In transit'
    when :pending then 'Waiting on Bank approval'
    when :rejected then 'Rejected'
    end
  end

  def state
    case status
    when :deposited then :success
    when :in_transit then :info
    when :pending then :pending
    when :rejected then :error
    end
  end

  def filter_data
    {
      exists: true,
      deposited: deposited?,
      in_transit: in_transit?,
      pending: pending?,
      rejected: rejected?
    }
  end

  def state_icon
    'checkmark' if deposited?
  end

  def pending_deprecated?
    approved_at.nil? && rejected_at.nil?
  end

  def approved?
    !pending?
  end

  def rejected_deprecated?
    rejected_at.present?
  end

  def in_transit_deprecated?
    approved_at.present?
  end

  def deposited_deprecated?
    t_transaction.present?
  end

  def admin_dropdown_description
    "#{event.name} - #{recipient_name} | #{ApplicationController.helpers.render_money amount}"
  end

  def approve!
    mark_in_transit!
    update(approved_at: DateTime.now)
  end

  def reject!
    mark_rejected!
    update(rejected_at: DateTime.now)
  end
end
