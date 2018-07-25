class GSuiteAccount < ApplicationRecord
  include Rejectable

  belongs_to :g_suite
  belongs_to :creator, class_name: 'User'

  validates_presence_of :address, :backup_email, :first_name, :last_name

  validate :status_accepted_or_rejected
  validates :address, uniqueness: { scope: :g_suite }

  scope :under_review, -> { where(rejected_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'accepted' if accepted_at.present?
    return 'verified' if verified_at.present?
    'pending'
  end

  def under_review?
    rejected_at.nil? && accepted_at.nil?
  end

  def verified?
    verified_at.present?
  end

  def username
    address.to_s.split('@').first
  end

  def at_domain
    "@#{address.to_s.split('@').last}"
  end
end
