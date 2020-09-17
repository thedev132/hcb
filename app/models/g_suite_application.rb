class GSuiteApplication < ApplicationRecord
  include Shared::Domain
  include Rejectable

  paginates_per 50

  belongs_to :creator, class_name: 'User'
  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :g_suite, required: false
  has_many :comments, as: :commentable

  validates_presence_of :creator, :event, :domain
  validate :status_accepted_canceled_or_rejected
  validates_presence_of :fulfilled_by, if: -> { rejected_at.present? || accepted_at.present? }
  validates_uniqueness_of :domain
  validate :domain_without_protocol, :domain_is_lowercase, :domain_not_email

  scope :under_review, -> { where(rejected_at: nil, canceled_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'canceled' if canceled_at.present?
    return 'accepted' if accepted_at.present?

    'under review'
  end

  def status_badge_type
    return :error if rejected_at.present?
    return :canceled if canceled_at.present?
    return :success if accepted_at.present?

    :pending
  end

  def under_review?
    rejected_at.nil? && canceled_at.nil? && accepted_at.nil?
  end

  def verification_url
    "https://www.google.com/webmasters/verification/verification?siteUrl=http://#{domain}"
  end
end
