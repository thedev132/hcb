class GSuiteApplication < ApplicationRecord
  include Rejectable

  belongs_to :creator, class_name: 'User'
  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :g_suite, required: false
  has_many :comments, as: :commentable

  validates_presence_of :creator, :event, :domain
  validate :status_accepted_canceled_or_rejected
  validates_presence_of :fulfilled_by, if: -> { rejected_at.present? || accepted_at.present? }
  validates_uniqueness_of :domain
  validate :domain_without_protocol, :domain_is_lowercase

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

  private

  def domain_without_protocol
    bad = ['http', ':', '/'].any? { |s| domain.include? s }
    errors.add(:domain, 'shouldn’t include http(s):// or ending /') if bad
  end

  def domain_is_lowercase
    return if domain.downcase == domain

    errors.add(:domain, 'must be all lowercase')
  end
end
