# frozen_string_literal: true

module Api
  module V1
    class OrganizationContract < Api::ApplicationContract
      params do
        required(:public_id).filled(:string)
      end
    end
  end
end
