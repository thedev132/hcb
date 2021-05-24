class Partner < ApplicationRecord
  has_many :events
  has_many :partner_donations
end
