class GSuite < ApplicationRecord
  has_one :application, class_name: 'GSuiteApplication', required: true
  has_many :accounts, class_name: 'GSuiteAccount'
  belongs_to :event
  has_many :comments, as: :commentable

  validates_presence_of :domain, :verification_key
  validates_uniqueness_of :domain
  validate :domain_without_protocol

  after_initialize :set_application
  after_create :notify_of_creation

  def verified?
    self.accounts.any? { |account| !account.verified_at.null? }
  end

  private

  def notify_of_creation
    GSuiteMailer.notify_of_creation(
      recipient: self.application.creator.email,
      g_suite: self
    )
  end

  def set_application
    self.application = GSuiteApplication.find_by(domain: self.domain)
  end

  def domain_without_protocol
    bad = ['http', ':', '/'].any? { |s| domain.include? s }
    errors.add(:domain, 'shouldn’t include http(s):// or ending /') if bad
  end
end
