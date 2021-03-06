module Partners
  module Lob
    module Shared
      def api_version
        "2018-06-05"
      end

      def api_key
        return Rails.application.credentials.lob[:production][:api_key] if Rails.env.production?

        Rails.application.credentials.lob[:development][:api_key]
      end

      def client
        @client ||= ::Lob::Client.new(api_key: api_key, api_version: api_version)
      end

      def bank_account
        if Rails.env.production?
          Rails.application.credentials.lob[:production][:bank_account_id]
        else
          Rails.application.credentials.lob[:development][:bank_account_id]
        end
      end

      def from_address
        if Rails.env.production?
          Rails.application.credentials.lob[:production][:from_address_id]
        else
          Rails.application.credentials.lob[:development][:from_address_id]
        end
      end
    end
  end
end
