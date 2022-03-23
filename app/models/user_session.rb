# frozen_string_literal: true

class UserSession < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :user
  belongs_to :impersonated_by, class_name: "User", required: false
  belongs_to :webauthn_credential, optional: true
  has_one :login_token, required: false

  scope :impersonated, -> { where.not(impersonated_by_id: nil) }
  scope :not_impersonated, -> { where(impersonated_by_id: nil) }

  # PEACEFUL VS UNPEACEFUL EXPIRATIONS
  # This is used to help determine if a user session's data (ip, etc.) can be
  # "trusted". Trusted sessions (peaceful sessions) are then used to determine
  # whether to relax or strength security measures for a user.
  #
  # Example use case:
  #   Only allow a user to use a magic login link IF the browser's IP was
  #   previously used by a trusted session.
  #
  # Implementation details:
  #   Sessions are considered unpeaceful if there is a chance the session may
  #   have been hijacked. These peaceful/unpeaceful classifications should be
  #   taken with a grain of salt since they're speculations and will have a lot
  #   of false "unpeaceful" sessions. So, it's probably best to use peaceful
  #   sessions to relax security measures, rather than use unpeaceful sessions
  #   to strengthen them.
  #
  #   - Peaceful
  #     - Normal sign out of current session
  #     - Normal time-based expiration
  #   - Unpeaceful
  #     - Sign out of all sessions
  #     - Sign out of a specific session
  #
  #
  # In order to use the following `peacefully_expired` scopes, you should also
  # use `act_as_paranoid`'s `only_deleted` scope since theoretically, a session
  # can only be peacefully_expired once it has been deleted.
  scope :peacefully_expired, -> { where(peacefully_expired: true) }
  scope :not_peacefully_expired, -> { where.not(peacefully_expired: true) }

  extend Geocoder::Model::ActiveRecord
  geocoded_by :ip
  after_validation :geocode, if: ->(session){ session.ip.present? and session.ip_changed? }

  def impersonated?
    !impersonated_by.nil?
  end

  def set_as_peacefully_expired
    # Don't let this raise exceptions, otherwise users can't sign out
    begin
      update(peacefully_expired: true)
    rescue => e
      Airbrake.notify e, session: self
      Rails.logger.error "Error setting session as peacefully expired: #{e.message}"
    end

    # Return self to allow chaining
    self
  end

end
