class Receipt < ApplicationRecord
  belongs_to :uploader, class_name: 'User'
  has_one_attached :image
end
