# frozen_string_literal: true

module ApiService
  module V1
    class ConnectStart
      def initialize(organization_identifier:, redirect_url:, webhook_url:)
        @organization_identifier = organization_identifier
        @redirect_url = redirect_url
        @webhook_url = webhook_url
      end

      def run
        ::Event.create!(attrs)
      end

      def attrs
        {
          partner: partner,
          organization_identifier: @organization_identifier,
          name: smart_name,
          slug: smart_slug,
          sponsorship_fee: sponsorship_fee,

          redirect_url: @redirect_url
        }
      end

      def smart_name
        @organization_identifier
      end

      def smart_slug
        @organization_identifier
      end

      def sponsorship_fee
        0.10 # 10% percent
      end

      def partner
        @partner ||= Partner.find_by!(slug: "bank") # TODO: contextual to who is using the API
      end
    end
  end
end

