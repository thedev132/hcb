class GSuiteApplication < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User'

  validates :creator, :event, :domain, :fulfilled_by, presence: true

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

  def rejected?
    rejected_at.present?
  end
end
