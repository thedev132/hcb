# frozen_string_literal: true

module EmburseClient
  module Transaction
    def self.search(search = nil)
      url = "v1/transactions"

      unless search.nil?
        allowed_params = %i{card member category department location label before after}
        filtered_search = search.select { |k, v| allowed_params.include?(k) }
        url << "?#{filtered_search.to_query}"
      end

      EmburseClient.request_paginated(url)
    end

    def self.list
      self.search
    end

    def self.get(id)
      EmburseClient.request("v1/transactions/#{id}")
    end
  end
end
