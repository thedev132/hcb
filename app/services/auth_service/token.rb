# frozen_string_literal: true

module AuthService
  class Token
    def initialize(token:)
      @token = token
    end

    def run
      ::LoginToken.active.find_by!(token: @token).user
    rescue ActiveRecord::RecordNotFound
      raise UnauthenticatedError
    end
  end
end
