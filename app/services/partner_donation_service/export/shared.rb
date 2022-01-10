# frozen_string_literal: true

module PartnerDonationService
  module Export
    module Shared
      def initialize(event_id:)
        @event_id = event_id
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def partner_donations
        @partner_donations ||= event.partner_donations.order("created_at desc")
      end

      def data_to_export
        {
          status: ->(pd) { pd.state },
          date: ->(pd) { pd.created_at },
          url: ->(pd) { Rails.application.routes.url_helpers.hcb_code_url(pd.local_hcb_code.hashid) },
          name: ->(pd) { pd.smart_memo },
          amount_cents: ->(pd) { pd.amount },
        }
      end

      def create_row(pd)
        data_to_export.map { |k, v| v[pd] }
      end

      def keys
        data_to_export.keys
      end
    end
  end
end
