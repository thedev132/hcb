class Disbursement < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_name, against: [:name]

  belongs_to :event
  belongs_to :source_event, class_name: 'Event'

  has_many :t_transactions, class_name: 'Transaction', inverse_of: :disbursement

  validates_presence_of :source_event_id,
                        :event_id,
                        :amount,
                        :name

  # Disbursement goes through four stages:
  # 1. Pending
  # 2. Processing
  # 3. Fulfilled
  # or, if not accepted...
  # 4. Rejected
  scope :pending, -> { where(fulfilled_at: nil, rejected_at: nil, errored_at: nil) }
  scope :processing, -> { where.not(fulfilled_at: nil).select { |d| d.processed? } }
  scope :fulfilled, -> { where.not(fulfilled_at: nil).select { |d| d.fulfilled? } }
  scope :rejected, -> { where.not(rejected_at: nil) }
  scope :errored, -> { where.not(errored_at: nil) }

  def pending?
    !processed? && !rejected? && !errored?
  end

  def processed?
    fulfilled_at.present?
  end

  def fulfilled?
    # two transactions, one coming out of source event and another
    # going into destination event
    t_transactions.size == 2
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
      :info
    elsif rejected?
      :error
    elsif errored?
      :error
    else
      :pending
    end
  end

  def state_text
    if fulfilled?
      'fulfilled'
    elsif processed?
      'processing'
    elsif rejected?
      'rejected'
    elsif errored?
      'errored'
    else
      'pending'
    end
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
end
