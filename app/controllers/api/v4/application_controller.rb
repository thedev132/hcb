# frozen_string_literal: true

module Api
  module V4
    class ApplicationController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include Pundit::Authorization

      after_action :verify_authorized

      before_action :authenticate!

      rescue_from Pundit::NotAuthorizedError do |e|
        render json: { error: "not_authorized" }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: "resource_not_found" }, status: :not_found
      end

      def not_found
        skip_authorization
        render json: { error: "not_found" }, status: :not_found
      end

      private

      def authenticate!
        @current_token = authenticate_with_http_token { |t, _options| ApiToken.find_by(token: t) }
        if @current_token.blank?
          return render json: { error: "invalid_auth" }, status: :unauthorized
        end

        @current_user = current_token&.user
      end

      attr_reader :current_token, :current_user

    end
  end
end
