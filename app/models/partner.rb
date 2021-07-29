# frozen_string_literal: true

class Partner < ApplicationRecord
  has_many :events
  has_many :partner_donations, through: :events

  encrypts :stripe_api_key, migrating: true
  # encrypts :stripe_api_key, type: :string

  # remove this line after dropping stripe_api_key column
  # self.ignored_columns = ["stripe_api_key"]
end
