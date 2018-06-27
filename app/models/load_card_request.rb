class LoadCardRequest < ApplicationRecord
  belongs_to :card
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :creator, class_name: 'User'

  scope :under_review, -> { where(rejected_at: nil, canceled_at: nil, accepted_at: nil) }

  def status
    return 'completed' if accepted_at.present?
    return 'canceled' if canceled_at.present?
    return 'rejected' if rejected_at.present?
    'under_review'
  end
end
