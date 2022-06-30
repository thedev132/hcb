# frozen_string_literal: true

module Api
  module Entities
    class Base < Grape::Entity
      include GrapeRouteHelpers::NamedRouteMatcher
      include Helpers::ExpandHelper

      expose :public_id, as: :id
      expose :object do |obj, options|
        self.class.object_type
      end
      expose :href do |obj, options|
        root = Rails.application.routes.url_helpers.root_url[0..-2] # remove trailing slash
        params = Hash["#{self.class.object_type}_id", obj.public_id]
        root + public_send(self.class.api_self_path_method_name, params)
      end

      format_with(:iso_timestamp) { |dt| dt.iso8601 }

      def self.entity_name
        self.name.demodulize.titleize
      end

      delegate :object_type, to: :class

      def self.object_type
        self.entity_name.gsub(' ', '_').underscore
      end

      def self.api_self_path_method_name
        "api_v3_#{self.object_type.pluralize}_path"
      end

      # FOR DEVELOPMENT TESTING
      # if Rails.env.development?
      #   expose :_options do
      #     expose :hide do |obj, opt|
      #       opt[:hide]
      #     end
      #     expose :expand do |obj, opt|
      #       opt[:expand]
      #     end
      #   end
      # end

    end
  end
end
