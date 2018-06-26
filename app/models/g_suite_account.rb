class GSuiteAccount < ApplicationRecord
  belongs_to :g_suite

  validates_presence_of :address

  def verified?
    verified_at.present?
  end
end
