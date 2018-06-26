class GSuiteApplication < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :event
  belongs_to :fulfilled_by, class_name: 'User'

  validates :creator, :event, :domain, :fulfilled_by, presence: true
end
