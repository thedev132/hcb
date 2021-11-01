# frozen_string_literal: true

module Api
  module V2
    class OrganizationsSerializer
      def initialize(organizations:)
        @organizations = organizations
      end

      def run
        {
          data: data
        }
      end

      private

      def data
        @organizations.map { |o| Api::V2::OrganizationSerializer.new(event: o).data }
      end

    end
  end
end
