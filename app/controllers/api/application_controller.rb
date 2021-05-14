# frozen_string_literal: true

module Api
  class ApplicationController < ::ActionController::Base
    layout false

    skip_before_action :verify_authenticity_token

    rescue_from ActiveRecord::RecordInvalid, with: :render_json_error_400
    rescue_from ActiveRecord::RecordNotUnique, with: :render_json_error_400
    rescue_from ArgumentError, with: :render_json_error_400

    private

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
