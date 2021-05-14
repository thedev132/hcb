# frozen_string_literal: true

module Api
  module V1
    class ConnectStartContract < Api::ApplicationContract
      params do
        required(:organizationIdentifier).filled(:string)
        required(:redirectUrl).filled(:string)
        required(:webhookUrl).filled(:string)

        optional(:name).filled(:string)
        optional(:email).filled(:string)
        optional(:phone).filled(:string)
        optional(:address).filled(:string)
        optional(:birthdate).filled(:string)
        optional(:organizationName).filled(:string)
        optional(:organizationUrl).filled(:string)
      end
    end
  end
end
