# frozen_string_literal: true

class Partner < ApplicationRecord
  EXCLUDED_SLUGS = %w(connect api donations donation connects organization organizations)

  has_many :events
  has_many :partner_donations, through: :events

  validates :slug, exclusion: { in: EXCLUDED_SLUGS }
  validates :api_key, presence: true, uniqueness: true

  before_create :set_api_key

  encrypts :stripe_api_key

  def regenerate_api_key!
    set_api_key(force: true)
    save!
  end

  private

  def set_api_key(force: false)
    self.api_key = "hcbk_" + SecureRandom.hex(32) if self.private_api_key.nil? || force
  end
end
