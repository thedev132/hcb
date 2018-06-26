class GSuiteAccount < ApplicationRecord
  belongs_to :g_suite

  validates :address, presence: true

  def verified?
    verified_at.present?
  end
end
