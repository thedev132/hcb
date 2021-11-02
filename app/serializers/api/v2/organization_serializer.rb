# frozen_string_literal: true

module Api
  module V2
    class OrganizationSerializer
      def initialize(event:)
        @event = event
      end

      def run
        result = {}
        result[:data] = data unless data.empty?
        result[:links] = links unless links.empty?
        result[:meta] = meta unless meta.empty?

        result
      end

      private

      def data # this method is also used by Api::V2::OrganizationsSerializer
        @data ||= {
          id: @event.public_id,
          name: @event.name,
          balance: @event.balance_v2_cents
        }
      end

      def links
        result = {}
        result[:self] = Rails.application.routes.url_helpers.api_v2_organization_url(@event.public_id)
        if @event.partnered_signup.present?
          result[:sup] = Rails.application.routes.url_helpers.api_v2_partnered_signup_url(public_id: @event.partnered_signup.public_id)
        end

        result
      end

      def meta
        @meta ||= {
          docs: 'https://bank.hackclub.com/docs/api#/Organizations/v2Organizations'
        }
      end
    end
  end
end
