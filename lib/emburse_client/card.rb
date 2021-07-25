# frozen_string_literal: true

module EmburseClient
  module Card
    def self.list
      EmburseClient.request_paginated("v1/cards")
    end

    def self.get(id)
      EmburseClient.request("v1/cards/#{id}")
    end

    def self.update(id, fields)
      EmburseClient.request("v1/cards/#{id}", :put, fields)
    end
  end
end
