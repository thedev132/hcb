# frozen_string_literal: true

module Api
  module V2
    class PartneredSignupsNewContract < Api::ApplicationContract
      params do
        required(:redirect_url).filled(:string)
        required(:organization_name).filled(:string)
        required(:owner_email).filled(:string)
        required(:owner_name).filled(:string)

        optional(:owner_phone).filled(:string)
        optional(:owner_address).filled(:string)
        optional(:owner_birthdate).filled(:string)
      end
    end
  end
end
