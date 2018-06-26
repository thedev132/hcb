class GSuiteAccount < ApplicationRecord
  belongs_to :g_suite

  validates :address, presence: true
end
