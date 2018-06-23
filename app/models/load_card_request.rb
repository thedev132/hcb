class LoadCardRequest < ApplicationRecord
  belongs_to :card
  belongs_to :fulfilled_by, class_name: 'User'
  belongs_to :user
end
