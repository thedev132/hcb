module UserService
  class GenerateToken
    def initialize(user_id:)
      @user_id = user_id
    end

    def run
      login_token = user.login_tokens.create!(attrs)
      login_token.token
    end

    private

    def attrs
      {
        token: token,
        expiration_at: expiration_at
      }
    end

    def expiration_at
      1.minute.from_now
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
  end
end
