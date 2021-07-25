# frozen_string_literal: true

module EmburseClient
  module Allowance
    def self.get(id)
      EmburseClient.request("v1/allowances/#{id}")
    end

    def self.update(id, fields)
      EmburseClient.request("v1/allowances/#{id}", :put, fields)
    end
  end
end
