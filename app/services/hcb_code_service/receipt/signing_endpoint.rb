# frozen_string_literal: true

module HcbCodeService
  module Receipt
    class SigningEndpoint
      def valid_url?(hashid, hmac)
        return false if hashid.blank? || hmac.blank?

        ActiveSupport::SecurityUtils.secure_compare(hmac, compute_hmac(hashid))
      end

      private

      if Rails.env.production?
        ENVIRONMENT_KEY = :production
      else
        ENVIRONMENT_KEY = :development
      end
      HMAC_KEY = Rails.application.credentials[:general_hmac_key][ENVIRONMENT_KEY]

      def compute_hmac(hashid)
        OpenSSL::HMAC.hexdigest("SHA256", HMAC_KEY, hashid).last(4)
      end

    end
  end
end
