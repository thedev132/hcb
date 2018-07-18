class EmburseTransaction < ApplicationRecord
  enum state: %w{pending completed declined}

  scope :pending, -> { where(state: 'pending') }
  scope :completed, -> { where(state: 'completed' )}
  scope :undeclined, -> { where.not(state: 'declined') }
  scope :declined, -> { where(state: 'declined' )}

  belongs_to :event, required: false

  validates_uniqueness_of :emburse_id
end
