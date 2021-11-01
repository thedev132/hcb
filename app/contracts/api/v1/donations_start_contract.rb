# frozen_string_literal: true

module Api
  module V1
    class DonationsStartContract < Api::ApplicationContract
      params do
        required(:organization_id).filled(:string)
      end
    end
  end
end
