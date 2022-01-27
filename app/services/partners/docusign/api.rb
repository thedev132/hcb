# frozen_string_literal: true

module Partners
  module Docusign
    # Api is a singleton service that abstracts away some of the complexities in creating
    # a Docusign request
    class Api
      # Service is a singleton because token refresh should be done sparingly.
      # We're going to use one instance per Server
      include Singleton

      if Rails.env.production?
        ENVIRONMENT_KEY = :production
      else
        ENVIRONMENT_KEY = :development
        attr_reader :api_client, :token
      end

      BASE_URI = Rails.application.credentials[:docusign][ENVIRONMENT_KEY][:account_base_uri]
      INTEGRATION_KEY = Rails.application.credentials[:docusign][ENVIRONMENT_KEY][:integration_key]
      USER_ID = Rails.application.credentials[:docusign][ENVIRONMENT_KEY][:user_id]
      PRIVATE_KEY = Rails.application.credentials[:docusign][ENVIRONMENT_KEY][:private_key]
      ACCOUNT_ID = Rails.application.credentials[:docusign][ENVIRONMENT_KEY][:account_id]

      def initialize
        configuration = DocuSign_eSign::Configuration.new
        configuration.host = BASE_URI
        unless Rails.env.production?
          configuration.debugging = true
        end

        @api_client = DocuSign_eSign::ApiClient.new configuration
        @api_client.base_path = BASE_URI + "/restapi"
        refresh_token
      end

      # Creates an envelop definition
      # @param [DocuSign_eSign::EnvelopeDefinition] envelope_definition
      # @param [Boolean] send_email
      # @return [DocuSign_eSign::EnvelopeSummary]
      def create_envelope(envelope_definition, send_email: true)
        refresh_token
        if send_email
          envelope_definition.status = "sent"
        end
        envelopes_api.create_envelope(ACCOUNT_ID, envelope_definition)
      end

      # Creates the view that recipients can sign within the app
      # @param [String] envelope_id
      # @param [String] signer_email
      # @param [String] signer_name
      # @param [String] signer_client_id
      # @param [String] callback_url
      # @return [DocuSign_eSign::ViewUrl]
      def create_recipient_view(envelope_id, signer_email, signer_name, signer_client_id, callback_url)
        refresh_token
        view_request = DocuSign_eSign::RecipientViewRequest.new
        view_request.return_url = callback_url
        view_request.authentication_method = "none"
        view_request.email = signer_email
        view_request.user_name = signer_name
        view_request.client_user_id = signer_client_id
        envelopes_api.create_recipient_view(ACCOUNT_ID, envelope_id, view_request)
      end

      def create_sender_view(envelope_id)
        refresh_token
        envelopes_api.create_sender_view(ACCOUNT_ID, envelope_id, {})
      end

      def get_envelope(envelope_id)
        refresh_token
        envelopes_api.get_envelope(ACCOUNT_ID, envelope_id)
      end

      def list_documents(envelope_id)
        refresh_token
        envelopes_api.list_documents(ACCOUNT_ID, envelope_id)
      end

      def get_document(envelope_id, document_id)
        refresh_token
        envelopes_api.get_document ACCOUNT_ID, document_id, envelope_id
      end

      private

      def envelopes_api
        DocuSign_eSign::EnvelopesApi.new @api_client
      end

      def refresh_token
        return if @token && @token_expiry.after?(DateTime.now)

        @token = @api_client.request_jwt_user_token(INTEGRATION_KEY, USER_ID, PRIVATE_KEY)
        # 2 minute buffer for token expiry
        @token_expiry = @token.expires_in.to_i.seconds.from_now.advance(minutes: -2)
      end

    end
  end
end
