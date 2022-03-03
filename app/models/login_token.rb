# frozen_string_literal: true

class LoginToken < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :user_session, optional: true
  belongs_to :partner, optional: true # The partner that requested this login link

  validates :token, presence: true
  validates :expiration_at, presence: true

  scope :active, -> { where("expiration_at >= ?", Time.now.utc) }

  include AASM

  aasm do
    state :unused, initial: true
    state :used

    event :mark_used do
      # The after callback sets the IP of the device that used the token.
      # Optionally pass in the IP when calling mark_used.
      # Example:
      #    login_token.mark_used!("my ip address here")
      #
      # It might seem excessive to store the IP since that data is accessible
      # via the user_session, however this IP field is useful in the case that
      # the user is forced to manually log in. In this case, there won't be a
      # user_session associated with the login_token.
      transitions from: :unused, to: :used, after: proc { |ip| self.update(ip: ip) if ip.present? }
    end
  end

  extend Geocoder::Model::ActiveRecord
  geocoded_by :ip
  after_validation :geocode, if: ->(session){ session.ip.present? and session.ip_changed? }

  def login_url
    # (@garyhtou) TODO: after login, redirect the user to the org.
    # Can be done by:
    #   - storing `go_to` url in token. Then when generating login url
    #   - add `go_to` as a query param and sign with HMAC to prevent tampering.
    #   - HMAC content should include the token to prevent replay attacks (make
    #     it non-detereministic).

    Rails.application.routes.url_helpers.api_v2_login_url(login_token: self.token)
  end

end
