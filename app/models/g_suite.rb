class GSuite < ApplicationRecord
  include Shared::Domain

  has_one :application, class_name: 'GSuiteApplication', required: true
  has_many :accounts, class_name: 'GSuiteAccount'
  belongs_to :event
  has_many :comments, as: :commentable

  validates_presence_of :domain, :verification_key
  validates_uniqueness_of :domain
  validate :domain_without_protocol

  after_initialize :set_application

  def verified?
    self.accounts.any? { |account| !account.verified_at.null? }
  end

  private

  def set_application
    self.application = GSuiteApplication.find_by(domain: domain)
  end
end
