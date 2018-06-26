class GSuite < ApplicationRecord
  has_one :g_suite_application
  has_many :g_suite_accounts
  belongs_to :event

  validates_presence_of :domain, :dns_verification_key
  validates :domain, format: { with: URI.regexp }, if: 'domain.present?'

  def verified?
    # one of the accounts is verified
  end
end
