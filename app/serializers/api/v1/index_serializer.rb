# frozen_string_literal: true

module Api
  module V1
    class IndexSerializer
      def run
        {
          data: [ data ]
        }
      end

      private

      def data
        {}
      end
    end
  end
end
