# frozen_string_literal: true

module Api
  module V2
    class ConnectFinishContract < Api::ApplicationContract
      params do
        required(:hashid).filled(:string)
        required(:name).filled(:string)
        required(:email).filled(:string)
        required(:phone).filled(:string)
        required(:address).filled(:string)
        required(:birthdate).filled(:string)
        required(:organization_name).filled(:string)
        optional(:organization_url).filled(:string)
      end
    end
  end
end
