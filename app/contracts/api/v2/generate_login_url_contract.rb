# frozen_string_literal: true

module Api
  module V2
    class GenerateLoginUrlContract < Api::ApplicationContract
      params do
        required(:organization_id).filled(:string)
        required(:email).filled(:string)
      end
    end
  end
end
