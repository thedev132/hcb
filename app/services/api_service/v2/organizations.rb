# frozen_string_literal: true

module ApiService
  module V2
    class Organizations
      def initialize(partner_id:)
        @partner_id = partner_id
      end

      def run
        partner.events
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end

    end
  end
end
