class Disbursement < ApplicationRecord
  belongs_to :event
  belongs_to :source_event, class_name: 'Event'

  has_many :t_transactions, class_name: 'Transaction', inverse_of: :check

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
  scope :pending, -> { where(fulfilled_at: nil, rejected_at: nil) }
  scope :processing, -> { where.not(fulfilled_at: nil).select {|d| d.processed?} }
  scope :fulfilled, -> { where.not(fulfilled_at: nil).select {|d| d.fulfilled?} }
  scope :rejected, -> { where.not(rejected_at: nil) }

  def pending?
    !processed? && !rejected?
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

  def filter_data
    {
      exists: true,
      pending: pending?,
      processing: processed?,
      fulfilled: fulfilled?,
      rejected: rejected?,
    }
  end

  def state
    if processed?
      :info
    elsif fulfilled?
      :success
    elsif rejected?
      :error
    else
      :pending
    end
  end

  def state_text
    if processed?
      'processing'
    elsif fulfilled?
      'fulfilled'
    elsif rejected?
      'rejected'
    else
      'pending'
    end
  end

  def mark_fulfilled!
    update(fulfilled_at: DateTime.now)
  end

  def admin_dropdown_description
    "#{amount} for #{name} to #{event.name}"
  end

  def transaction_memo
    "HCB DISBURSE #{id}"
  end
end
