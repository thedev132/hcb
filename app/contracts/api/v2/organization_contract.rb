# frozen_string_literal: true

module Api
  module V2
    class OrganizationContract < Api::ApplicationContract
      params do
        required(:public_id).filled(:string)
      end
    end
  end
end
