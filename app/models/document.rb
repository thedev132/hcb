class Document < ApplicationRecord
  belongs_to :event
  belongs_to :user

  has_one_attached :file

  validates_presence_of :event, :user, :file
end
