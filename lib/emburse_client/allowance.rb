module EmburseClient
  module Allowance
    def self.get(id)
      EmburseClient.request("v1/allowances/#{id}")
    end
  end
end
