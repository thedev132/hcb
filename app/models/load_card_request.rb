class LoadCardRequest < ApplicationRecord
  belongs_to :card
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :creator, class_name: 'User'

  scope :outstanding, -> { where(fulfilled_by_id: nil) }

  def status
    return 'completed' if fulfilled_by_id.present?
    'under review'
  end
end
