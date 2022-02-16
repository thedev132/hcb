# frozen_string_literal: true

class Comment < ApplicationRecord
  include Hashid::Rails

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  has_one_attached :file

  has_paper_trail

  validates :user, presence: true
  validates :content, presence: true, unless: :has_attached_file?

  validate :commentable_includes_concern

  scope :admin_only, -> { where(admin_only: true) }
  scope :not_admin_only, -> { where(admin_only: false) }
  scope :edited, -> { joins(:versions).where("has_untracked_edit IS TRUE OR versions.event = 'update' OR versions.event = 'destroy'") }
  scope :has_attached_file, -> { joins(:file_attachment) }

  def edited?
    has_untracked_edit? or
      versions.where("event = 'update' OR event = 'destroy'").any?
  end

  def has_attached_file?
    file.attached?
  end

  private

  def commentable_includes_concern
    unless commentable.class.included_modules.include?(Commentable)
      errors.add(:commentable_type, "is not commentable")
    end
  end

end
