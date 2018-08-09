class EmburseTransaction < ApplicationRecord
  enum state: %w{pending completed declined}

  scope :pending, -> { where(state: 'pending') }
  scope :completed, -> { where(state: 'completed' )}
  scope :undeclined, -> { where.not(state: 'declined') }
  scope :declined, -> { where(state: 'declined' )}

  belongs_to :event, required: false
  belongs_to :card, required: false

  validates_uniqueness_of :emburse_id

  def emburse_path
    "https://app.emburse.com/transactions/#{emburse_id}"
  end

  def status_badge_type
    s = state.to_sym
    return 'success' if s == :completed
    return 'error' if s == :declined
    'pending'
  end

  def self.total_card_transaction_volume
    -self.where('amount < 0').completed.sum(:amount)
  end

  def self.total_card_transaction_count
    self.where('amount < 0').completed.count
  end
end
