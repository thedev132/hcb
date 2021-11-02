# frozen_string_literal: true

module Api
  module V2
    class PartneredSignupSerializer
      def initialize(partnered_signup:)
        @partnered_signup = partnered_signup
      end

      def run
        result = {}
        result[:data] = data unless data.empty?
        result[:links] = links unless links.empty?
        result[:meta] = meta unless meta.empty?

        result
      end


      def data
        @data ||= {
          id: @partnered_signup.public_id,
          status: @partnered_signup.status,
          redirect_url: @partnered_signup.redirect_url,
          connect_url: @partnered_signup.continue_url,
          owner_email: @partnered_signup.owner_email,
          organization_name: @partnered_signup.organization_name,
          organization_id: @partnered_signup.event&.public_id, # nil if event does not exist yet

          ## (@msw) These fields are intentionally not public– this info should not leave bank
          # owner_name: @partnered_signup.owner_name,
          # owner_phone: @partnered_signup.owner_phone,
          # owner_address: @partnered_signup.owner_address,
          # owner_birthdate: @partnered_signup.owner_birthdate,
          # country: @partnered_signup.country,
        }
      end

      def links
        result = {}

        result[:self] = Rails.application.routes.url_helpers.api_v2_partnered_signup_url(public_id: @partnered_signup.public_id)
        if @partnered_signup.event
          result[:org] = Rails.application.routes.url_helpers.api_v2_organization_url(public_id: @partnered_signup.event.public_id)
        end

        result
      end

      def meta
        @meta ||= {
          docs: "https://bank.hackclub.com/docs/api#/Bank%20Connect%20(PartneredSignups)/v2PartneredSignups"
        }
      end
    end
  end
end
