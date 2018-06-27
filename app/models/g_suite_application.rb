class GSuiteApplication < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User', required: false

  validates_presence_of :creator, :event, :domain
  validates_uniqueness_of :domain
  validate :domain_without_protocol

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
    bad = ['http', ':', '/'].any? { |s| domain.include? s }
    errors.add(:domain, 'shouldn’t include http(s):// or ending /') if bad
  end
end
