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
        optional(:owner_address_line1).filled(:string)
        optional(:owner_address_line2).filled(:string)
        optional(:owner_address_city).filled(:string)
        optional(:owner_address_postal_code).filled(:string)
        optional(:owner_address_country).filled(:integer)
        optional(:owner_birthdate).filled(:string)
      end

    end
  end
end
