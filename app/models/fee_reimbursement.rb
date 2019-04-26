class FeeReimbursement < ApplicationRecord
  has_one :invoice
  has_one :t_transaction, class_name: 'Transaction'

  after_initialize :default_values

  scope :unprocessed, -> { where(processed_at: nil, t_transaction: nil) }
  scope :pending, -> { where.not(processed_at: nil) }
  scope :completed, -> { where.not(t_transaction: nil) }

  def unprocessed?
    processed_at.nil? && t_transaction.nil?
  end

  def pending?
    !processed_at.nil?
  end

  def completed?
    !t_transaction.nil?
  end

  def status
    return 'completed' if completed?
    return 'pending' if pending?
    'unprocessed'
  end

  def process
    processed_at = DateTime.now
  end

  private

  def default_values
    self.transaction_memo = "#{self.invoice.slug} FEE REIMBURSEMENT"
  end

end
