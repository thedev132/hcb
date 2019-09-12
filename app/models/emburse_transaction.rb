class EmburseTransaction < ApplicationRecord
  enum state: %w{pending completed declined}

  acts_as_paranoid
  validates_as_paranoid

  scope :pending, -> { where(state: 'pending') }
  scope :completed, -> { where(state: 'completed') }
  scope :undeclined, -> { where.not(state: 'declined') }
  scope :declined, -> { where(state: 'declined') }
  scope :under_review, -> { where(event_id: nil).undeclined }

  belongs_to :event, required: false
  belongs_to :card, required: false

  validates_uniqueness_of_without_deleted :emburse_id

  def under_review?
    event_id.nil? && undeclined? && !should_be_ignored?
  end

  # Emburse surfaces pending transactions of two types:
  # 1. expenses, which are negative TXs signifying money spent on Emburse cards
  # 2. deposits, which are TXs we make to move money from Bank to Emburse
  #
  # No. 2 (deposits) shouldn't really be triaged until they become COMPLETED. So
  # we ignore them for the purposes of reviewing transactions.
  def should_be_ignored?
    :pending && amount > 0
  end

  def undeclined?
    state != 'declined'
  end

  def completed?
    state == 'completed'
  end

  def emburse_path
    "https://app.emburse.com/transactions/#{emburse_id}"
  end

  def status_badge_type
    s = state.to_sym
    return :success if s == :completed
    return :error if s == :declined

    :pending
  end

  def self.total_card_transaction_volume
    -self.where('amount < 0').completed.sum(:amount)
  end

  def self.total_card_transaction_count
    self.where('amount < 0').completed.size
  end
end
