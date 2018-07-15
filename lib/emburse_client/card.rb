module EmburseClient
  module Card
    def self.list
      EmburseClient.request('v1/cards')
    end
  end
end
