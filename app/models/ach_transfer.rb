class AchTransfer < ApplicationRecord
  include Commentable

  belongs_to :creator, class_name: 'User'
  belongs_to :event

  validates_length_of :routing_number, is: 9

  has_one :t_transaction, class_name: 'Transaction', inverse_of: :ach_transfer

  scope :pending, -> { where(approved_at: nil, rejected_at: nil) }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }

  def self.in_transit
    select { |a| a.approved_at.present? && a.t_transaction.nil? }
  end

  def self.delivered
    select { |a| a.t_transaction.present? }
  end

  def status
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

  def pending?
    approved_at.nil? && rejected_at.nil?
  end

  def approved?
    !pending?
  end

  def rejected?
    rejected_at.present?
  end

  def in_transit?
    approved_at.present?
  end

  def deposited?
    t_transaction.present?
  end

  def admin_dropdown_description
    "#{event.name} - #{recipient_name} | #{ApplicationController.helpers.render_money amount}"
  end

  def approve!
    if !pending?
      errors.add(:ach_transfer, 'has already been approved or rejected!')
      return false
    end
    update(approved_at: DateTime.now)
  end

  def reject!
    if !pending?
      errors.add(:ach_transfer, 'has already been approved or rejected!')
      return false
    end
    update(rejected_at: DateTime.now)
  end
end
