class GSuiteApplication < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User', required: false

  validates_presence_of :creator, :event, :domain
  validates_uniqueness_of :domain
  validate :domain_without_protocol

  scope :outstanding, -> { where(accepted_at: nil) }
  scope :under_review, -> { where(rejected_at: nil, canceled_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'canceled' if canceled_at.present?
    return 'accepted' if accepted_at.present?
    'under review'
  end

  def under_review?
    rejected_at.nil? && canceled_at.nil? && accepted_at.nil?
  end

  def accepted?
    accepted_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  private

  def domain_without_protocol
    uri = URI.parse(domain)
    uri.scheme.nil?
  end
end
