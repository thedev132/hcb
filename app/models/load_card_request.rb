class LoadCardRequest < ApplicationRecord
  belongs_to :card
  belongs_to :user
  belongs_to :user
end
