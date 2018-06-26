class GSuite < ApplicationRecord
  has_one :g_suite_application
  has_many :g_suite_accounts
  belongs_to :event

  validates_presence_of :domain, :dns_verification_key
  validates_uniqueness_of :domain 
  validates :domain, format: { with: URI.regexp }, if: lambda { domain.present? }

  def verified?
    self.g_suite_accounts.any? { |account| !account.verified_at.null? }
  end
end
