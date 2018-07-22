class Document < ApplicationRecord
  belongs_to :event
  belongs_to :user

  has_one_attached :file
  has_many :downloads, class_name: 'DocumentDownload'

  validates_presence_of :event, :user
  validate :ensure_file_attached

  private

  # ActiveStorage doesn't yet support attachment validation (how dumb... see
  # https://github.com/rails/rails/issues/31656). This manually checks if a
  # file is attached for the time being.
  def ensure_file_attached
    errors.add(:file, 'must be attached') unless file.attached?
  end
end
