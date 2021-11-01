# frozen_string_literal: true

module Api
  module V2
    class PartneredSignupsSerializer
      def initialize(partnered_signups:)
        @partnered_signups = partnered_signups
      end

      def run
        {
          data: data
        }
      end

      private

      def data
        @partnered_signups.map { |sup| Api::V2::PartneredSignupSerializer.new(partnered_signup: sup).data }
      end

    end
  end
end
