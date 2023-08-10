# frozen_string_literal: true

module Api
  module Entities
    class DirectoryOrganization < Api::Entities::Base
      def self.is_transparent?
        ->(org, _) { org.is_public? }
      end

      expose :name
      expose :description

      expose :slug, if: is_transparent?
      expose :website
      expose :is_public, as: :transparent
      expose :location do
        expose :country, as: :country_code
        expose :country do |organization|
          ISO3166::Country.new(organization.country)&.common_name
        end
        expose :continent do |organization|
          ISO3166::Country.new(organization.country)&.continent
        end
      end

      expose :category do |organization|
        organization.category&.parameterize&.underscore
      end
      expose :missions do |organization|
        # This is written with filtering in Ruby rather than SQL to use
        # previously loaded data and prevent an N+1.
        organization.event_tags
                    .select { |tag| tag.purpose == :mission }
                    .map { |tag| tag.api_name(:short) }
      end
      expose :climate do |organization|
        # This is written with filtering in Ruby rather than SQL to use
        # previously loaded data and prevent an N+1.
        organization.event_tags.any? do |tag|
          tag.name == EventTag::Tags::CLIMATE && tag.purpose == "directory"
        end
      end

      expose :logo do |organization|
        url_for_attached organization.logo
      end
      expose :background_image do |organization|
        url_for_attached organization.background_image
      end
      expose :donation_link do |organization|
        if organization.donation_page_enabled?
          Rails.application.routes.url_helpers.start_donation_donations_url(organization)
        else
          nil
        end
      end

      unexpose :href

    end
  end
end
