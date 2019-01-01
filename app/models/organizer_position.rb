class OrganizerPosition < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  belongs_to :user
  belongs_to :event

  def delete!
  	self.deleted_at = Time.current
  	self.save
  end

  def active?
  	return true unless self.deleted_at.present?
  end


  validates :user, uniqueness: { scope: :event }

  has_one :organizer_position_invite
end
