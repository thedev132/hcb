# frozen_string_literal: true

module Partners
  module Docusign
    class PartneredSignupContract
      # ID of the template sent to the user, this isn't private so
      # we're good to store it here
      # @param [PartneredSignup] partnered_signup
      def initialize(partnered_signup)
        @partnered_signup = partnered_signup
        @docusign_api = Partners::Docusign::Api.instance
      end

      def create
        e = @docusign_api.create_envelope(envelope)
        {
          signing_url: get_signing_url(e.envelope_id),
          envelope: e,
        }
      end

      # TODO: webhook to register signing completion
      def get_signing_url(envelope_id)
        @docusign_api.create_recipient_view(
          envelope_id,
          @partnered_signup.owner_email,
          @partnered_signup.owner_name,
          @partnered_signup.id,
          Partners::Docusign::SigningCompletionRedirect.new.create(@partnered_signup),
        ).url
      end

      private

      def envelope
        envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
        envelope_definition.template_id = @partnered_signup.partner.docusign_template_id
        envelope_definition.template_roles = [
          DocuSign_eSign::TemplateRole.new(
            {
              email: @partnered_signup.owner_email,
              name: @partnered_signup.owner_name,
              roleName: "signer",
              clientUserId: @partnered_signup.id,
            }
          )
        ]
        envelope_definition
      end

    end
  end
end
