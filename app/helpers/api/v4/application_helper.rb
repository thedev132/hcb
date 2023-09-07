# frozen_string_literal: true

module Api
  module V4
    module ApplicationHelper
      def pagination_metadata(json)
        json.total_count @total_count
        json.has_more @has_more
      end

    end
  end
end
