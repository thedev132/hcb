class OrganizerPositionDeletionRequest < ApplicationRecord
  belongs_to :submitted_by, class_name: 'User'
  belongs_to :closed_by, class_name: 'User', required: false
  belongs_to :organizer_position, -> { with_deleted }

  has_many :comments, as: :commentable

  scope :under_review, -> { where(closed_at: nil) }

  validates_presence_of :reason

  def under_review?
    closed_at == nil
  end

  def status
    if closed_at == nil
      :under_review
    else
      :closed
    end
  end
end
