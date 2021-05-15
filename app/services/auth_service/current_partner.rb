# frozen_string_literal: true

module AuthService
  class CurrentPartner
    def initialize(bearer_token:)
      @bearer_token = bearer_token
    end

    def run
      ::Partner.find_by!(api_key: @bearer_token)
    rescue ActiveRecord::RecordNotFound
      raise UnauthenticatedError
    end
  end
end
