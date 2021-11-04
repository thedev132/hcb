# frozen_string_literal: true

module Api
  module V2
    class DonationsNewContract < Api::ApplicationContract
      params do
        required(:organization_id).filled(:string)
      end
    end
  end
end
