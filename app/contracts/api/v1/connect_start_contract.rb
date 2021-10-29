# frozen_string_literal: true

module Api
  module V1
    class ConnectStartContract < Api::ApplicationContract
      params do
        required(:redirect_url).filled(:string)
        required(:organization_name).filled(:string)
      end
    end
  end
end
