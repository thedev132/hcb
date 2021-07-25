# frozen_string_literal: true

class Partner < ApplicationRecord
  has_many :events
  has_many :partner_donations, through: :events
end
