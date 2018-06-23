class LoadCardRequest < ApplicationRecord
  belongs_to :card
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :creator, class_name: 'User'
end
