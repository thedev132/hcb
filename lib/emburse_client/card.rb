module EmburseClient
  module Card
    def self.list
      EmburseClient.request('v1/cards')
    end

    def self.get(id)
      EmburseClient.request("v1/cards/#{id}")
    end
  end
end
