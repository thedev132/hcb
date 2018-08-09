module EmburseClient
  module Department
    def self.list
      EmburseClient.request('v1/departments')
    end

    def self.get(id)
      EmburseClient.request("v1/departments/#{id}")
    end
  end
end
