class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  has_one_attached :file

  validates_presence_of :content, :user
end
