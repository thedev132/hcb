class GSuite < ApplicationRecord
  has_one :g_suite_application
  belongs_to :event

  validates :domain, :dns_verification_key, presence: true
end
