class GSuite < ApplicationRecord
  has_one :g_suite_application
  has_many :g_suite_accounts
  belongs_to :event

  validates_presence_of :domain, :verification_key
  validates_uniqueness_of :domain
  validate :domain_without_protocol

  def verified?
    self.g_suite_accounts.any? { |account| !account.verified_at.null? }
  end

  private

  def domain_without_protocol
    bad = ['http', ':', '/'].any? { |s| domain.include? s }
    errors.add(:domain, 'shouldn’t include http(s):// or ending /') if bad
  end
end
