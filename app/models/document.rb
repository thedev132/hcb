class Document < ApplicationRecord
  include FriendlyId

  friendly_id :slug_text, use: :slugged

  belongs_to :event, optional: true
  belongs_to :user

  has_one_attached :file
  has_many :downloads, class_name: 'DocumentDownload'

  validates_presence_of :user, :name
  validate :ensure_file_attached

  scope :common, -> { where(event_id: nil) }

  def preview_url(resize: '500x500')
    return nil unless file

    case file.content_type
    when 'application/pdf'
      return nil unless file.previewable?

      file.preview(resize: resize)
    else
    end
  end

  private

  # ActiveStorage doesn't yet support attachment validation (how dumb... see
  # https://github.com/rails/rails/issues/31656). This manually checks if a
  # file is attached for the time being.
  def ensure_file_attached
    errors.add(:file, 'must be attached') unless file.attached?
  end

  def slug_text
    "#{self.event ? self.event.name : 'common'} #{self.name}"
  end
end
