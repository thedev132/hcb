# frozen_string_literal: true

module Partners
  module Docusign
    class SigningCompletionRedirect
      if Rails.env.production?
        ENVIRONMENT_KEY = :production
      else
        ENVIRONMENT_KEY = :development
      end
      HMAC_KEY = Rails.application.credentials[:docusign][ENVIRONMENT_KEY][:hmac_key]

      # Creates a redirect URL that is protected by a HMAC so it isn't forge-able
      def create(partnered_signup, role: :recipient)
        timestamp = Time.now.to_i.to_s
        partnered_signup_id = partnered_signup.id.to_s
        hmac = compute_hmac(partnered_signup_id, timestamp, role)
        Rails.application.routes.url_helpers.docusign_signing_complete_redirect_url(
          timestamp:,
          partnered_signup_id:,
          hmac:,
          role:
        )
      end

      # Validates webhook by checking comparing the provided HMAC with a computed one
      # @param [String] partnered_signup_id
      # @param [String] timestamp
      # @param [String] hmac
      def valid_webhook?(partnered_signup_id, timestamp, hmac, role)
        ActiveSupport::SecurityUtils.secure_compare(hmac, compute_hmac(partnered_signup_id, timestamp, role.to_s))
      end

      private

      def compute_hmac(partnered_signup_id, timestamp, role)
        OpenSSL::HMAC.hexdigest("SHA256", HMAC_KEY, partnered_signup_id + "#" + timestamp + "#" + role.to_s)
      end

    end
  end
end
