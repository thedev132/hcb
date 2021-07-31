# frozen_string_literal: true

class Partner < ApplicationRecord
  EXCLUDED_SLUGS = %w(connect api donations donation connects organization organizations)

  has_many :events
  has_many :partner_donations, through: :events

  validates :slug, exclusion: { in: EXCLUDED_SLUGS }
  
  encrypts :stripe_api_key, migrating: true
  # encrypts :stripe_api_key, type: :string

  # remove this line after dropping stripe_api_key column
  # self.ignored_columns = ["stripe_api_key"]
end
