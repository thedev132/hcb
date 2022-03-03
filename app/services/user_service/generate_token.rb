# frozen_string_literal: true

module UserService
  class GenerateToken
    def initialize(partner_id:, user_id:)
      @partner_id = partner_id
      @user_id = user_id
    end

    def run
      user.login_tokens.create!(attrs)
    end

    private

    def attrs
      {
        token: token,
        expiration_at: expiration_at,
        partner: partner
      }
    end

    def expiration_at
      # Tokens (login urls) must be generated on demand
      15.seconds.from_now
    end

    def token
      loop do
        @token = generate_a_token

        break unless LoginToken.find_by(token: @token)
      end

      @token
    end

    def generate_a_token
      "tok_#{SecureRandom.alphanumeric(32)}"
    end

    def user
      @user ||= ::User.find(@user_id)
    end

    def partner
      @partner ||= ::Partner.find(@partner_id)
    end

  end
end
