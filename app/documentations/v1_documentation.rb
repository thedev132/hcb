# frozen_string_literal: true

class V1Documentation < ApplicationDocumentation
  swagger_path "/v1" do
    operation :get do
      key :summary, "GET v1"
      key :description, "Test if API live"
      key :tags, ["v1"]
      key :operationId, "v1"

      response 200 do
        key :description, "v1 response"
        content :"application/json" do
          key :example, {
            data: [
              {}
            ]
          }
        end
      end
    end
  end
end
