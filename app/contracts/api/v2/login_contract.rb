# frozen_string_literal: true

module Api
  module V2
    class LoginContract < Api::ApplicationContract
      params do
        required(:login_token).filled(:string)
      end
    end
  end
end
