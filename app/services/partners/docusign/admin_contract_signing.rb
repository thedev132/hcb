# frozen_string_literal: true

module Partners
  module Docusign
    class AdminContractSigning
      def initialize(partnered_signup)
        @partnered_signup = partnered_signup
        @docusign_api = Partners::Docusign::Api.instance
      end

      def admin_signing_link
        @docusign_api.create_sender_view(
          @partnered_signup.docusign_envelope_id,
        ).url
      end

    end
  end
end
