class GSuite < ApplicationRecord
  has_one :g_suite_application
  belongs_to :event

  validates_presence_of :domain, :dns_verification_key
  validates :domain, format: { with: URI.regexp }, if: 'domain.present?'
end
