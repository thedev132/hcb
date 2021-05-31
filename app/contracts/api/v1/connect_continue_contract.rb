# frozen_string_literal: true

module Api
  module V1
    class ConnectContinueContract < Api::ApplicationContract
      params do
        required(:hashid).filled(:string)
      end
    end
  end
end
