# frozen_string_literal: true

class LoginToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :expiration_at, presence: true
end
