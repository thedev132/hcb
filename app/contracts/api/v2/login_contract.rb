# frozen_string_literal: true

module Api
  module V2
    class LoginContract < Api::ApplicationContract
      params do
        required(:loginToken).filled(:string)
      end
    end
  end
end
