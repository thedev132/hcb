# frozen_string_literal: true

class LoginToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :expiration_at, presence: true

  scope :active, -> { where("expiration_at >= ?", Time.now.utc) }

end
