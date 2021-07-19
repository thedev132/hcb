# frozen_string_literal: true

module Api
  class ApplicationController < ::ActionController::Base
    layout false

    skip_before_action :verify_authenticity_token
    before_action :authenticate

    rescue_from ActiveRecord::RecordInvalid, with: :render_json_error_400
    rescue_from ActiveRecord::RecordNotUnique, with: :render_json_error_400
    rescue_from ArgumentError, with: :render_json_error_400
    rescue_from UnauthenticatedError, UnauthorizedError do |e|
      error_generic(e)
    end

    private

    # replaces SessionsHelper::sign_in
    def sign_in_and_set_cookie!(user)
      session_token = SecureRandom.urlsafe_base64
      digest_token = Digest::SHA1.hexdigest(session_token)

      cookies.permanent[:session_token] = session_token
      user.update_column(:session_token, digest_token)

      @current_user ||= user
    end

    def current_partner
      @current_partner
    end

    def authenticate
      @current_partner = AuthService::CurrentPartner.new(bearer_token: bearer_token).run
    end

    def bearer_token
      @bearer_token ||= validate_token
    end

    def validate_token
      return nil if !request.headers["Authorization"].present?

      auth_header = request.headers["Authorization"].split(" ")
      return auth_header[1] if auth_header.size == 2 && auth_header[0] == "Bearer"

      nil
    end

    def error_generic(exception)
      json = {
        errors: [
          {
            code: nil, # our own internal codes for added detail (future use)
            status: exception.status, # http status
            message: exception.message
          }
        ]
      }

      render json: json, status: exception.status
    end

    def json_error(contract)
      message = "#{contract.errors.first.path} #{contract.errors.first.text}."

      {
        errors: [
          {
            status: 400,
            code: nil,
            message: message,
            input: contract.errors.first.input
          }
        ]
      }
    end

    def render_json_error_400(exception)
      message = exception.message

      json = {
        errors: [
          {
            status: 400,
            code: nil,
            message: message,
          }
        ]
      }

      render json: json, status: 400 and return
    end

    def render_json_error_500(exception)
      message = exception.message

      json = {
        errors: [
          {
            status: 500,
            code: nil,
            message: message,
          }
        ]
      }

      render json: json, status: 500 and return
    end
  end
end
