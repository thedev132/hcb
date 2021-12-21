# frozen_string_literal: true

class Comment < ApplicationRecord
  include Hashid::Rails

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  has_one_attached :file

  validates :user, presence: true
  validates :content, presence: true, unless: :file_is_attached?

  validate :commentable_includes_concern

  scope :admin_only, -> { where(admin_only: true) }
  scope :not_admin_only, -> { where(admin_only: false) }

  private

  def commentable_includes_concern
    unless commentable.class.included_modules.include?(Commentable)
      errors.add(:commentable_type, "is not commentable")
    end
  end

  def file_is_attached?
    file.attached?
  end
end
