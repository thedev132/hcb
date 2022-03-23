# frozen_string_literal: true

class WebauthnCredential < ApplicationRecord
  belongs_to :user

  enum authenticator_type: [:platform, :cross_platform]

  validates :name, presence: true
  validates :webauthn_id, presence: true
  validates :public_key, presence: true
  validates :sign_count, presence: true

end
