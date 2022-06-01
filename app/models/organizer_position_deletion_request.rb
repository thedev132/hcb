# frozen_string_literal: true

class OrganizerPositionDeletionRequest < ApplicationRecord
  has_paper_trail

  include Commentable

  belongs_to :submitted_by, class_name: "User"
  belongs_to :closed_by, class_name: "User", required: false
  belongs_to :organizer_position, with_deleted: true

  scope :under_review, -> { where(closed_at: nil) }

  validates_presence_of :reason

  def under_review?
    closed_at.nil?
  end

  def status
    if organizer_position.deleted_at.present?
      :organizer_deleted
    elsif under_review?
      :under_review
    else
      :closed
    end
  end

  def status_badge_type
    if organizer_position.deleted_at.present?
      :primary
    elsif under_review?
      :pending
    else
      :success
    end
  end

  def close(closed_by)
    raise StandardError.new("Already closed") unless self.closed_at.nil?

    self.closed_by = closed_by
    self.closed_at = Time.now
    self.save
  end

  def open
    self.closed_by = nil
    self.closed_at = nil
    self.save
  end

end
