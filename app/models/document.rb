# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id         :bigint           not null, primary key
#  name       :text
#  slug       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_documents_on_event_id  (event_id)
#  index_documents_on_slug      (slug) UNIQUE
#  index_documents_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class Document < ApplicationRecord
  include FriendlyId

  friendly_id :slug_text, use: :slugged

  belongs_to :event, optional: true
  belongs_to :user

  has_one_attached :file
  has_many :downloads, class_name: "DocumentDownload", dependent: :destroy

  validates_presence_of :user, :name
  validate :ensure_file_attached

  scope :common, -> { where(event_id: nil) }

  def preview_url(resize: [500, 500])
    return nil unless file

    case file.content_type
    when "application/pdf"
      return nil unless file.previewable?

      file.preview(resize_to_limit: resize)
    else
    end
  end

  def common?
    event_id.nil?
  end

  private

  # ActiveStorage doesn't yet support attachment validation (how dumb... see
  # https://github.com/rails/rails/issues/31656). This manually checks if a
  # file is attached for the time being.
  def ensure_file_attached
    errors.add(:file, "must be attached") unless file.attached?
  end

  def slug_text
    "#{self.event ? self.event.name : 'common'} #{self.name}"
  end

end
