class FeeReimbursement < ApplicationRecord
  has_one :invoice
  has_one :transaction

  after_initialize :default_values

  scope :unprocessed, -> { where(processed_at: nil && transaction: nil) }
  scope :pending, -> { where.not(processed_at: nil) }
  scope :completed, -> { where.not(transaction: nil) }

  def process
    processed_at = DateTime.now
  end

  private

  def default_values
    self.transaction_memo = "#{self.invoice.slug} FEE REIMBURSEMENT"
  end

end
