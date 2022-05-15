# frozen_string_literal: true

module HcbCodeService
  module Receipt
    class SigningEndpoint
      if Rails.env.production?
        ENVIRONMENT_KEY = :production
      else
        ENVIRONMENT_KEY = :development
      end
      HMAC_KEY = Rails.application.credentials[:general_hmac_key][ENVIRONMENT_KEY]

      def create(hcb_code)
        hashid = hcb_code.hashid
        hmac = compute_hmac(hashid)
        Rails.application.routes.url_helpers.attach_receipt_hcb_code_url(
          id: hashid,
          s: hmac
        )
      end

      def valid_url?(hashid, hmac)
        ActiveSupport::SecurityUtils.secure_compare(hmac, compute_hmac(hashid))
      end

      private

      def compute_hmac(hashid)
        OpenSSL::HMAC.hexdigest("SHA256", HMAC_KEY, hashid).last(4)
      end

    end
  end
end
