# frozen_string_literal: true

class DonationsV1Documentation < ApplicationDocumentation
  swagger_path "/api/donations/v1/start" do
    operation :post do
      key :summary, "Start a donation backed by Bank"
      key :description, "Start a donation backed by Bank"
      key :tags, ["Donations"]
      key :operationId, "connectV1Webhook"

      parameter do
        key :name, :organizationIdentifier
        key :in, :query
        key :description, "The unique organization identifier obtained during the Bank Connect process"
        key :required, true
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, "Parse this data in order to inject the donationIdentifier into the Stripe Charge metadata"
        content :"application/json" do
          key :example, {
            data: [
              {
                organizationIdentifier: "org_1234",
                donationIdentifier: "dnt_1234"
              }
            ]
          }
        end
      end
    end
  end
end
