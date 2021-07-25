# frozen_string_literal: true

class V1ConnectDocumentation < ApplicationDocumentation
  swagger_path "/api/v1/connect/start" do
    operation :post do
      key :summary, "Send user through Bank Connect flow"
      key :description, "Send user through Bank Connect flow"
      key :tags, ["Connect"]
      key :operationId, "v1ConnectStart"

      parameter do
        key :name, :organizationIdentifier
        key :in, :query
        key :description, "Uniquely identify the organization applying through Bank Connect"
        key :required, true
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :redirectUrl
        key :in, :query
        key :description, "Bank Connect redirects to this page after the user finishes the Bank Connect flow"
        key :required, true
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :webhookUrl
        key :in, :query
        key :description, "Bank Connect sends a webhook payload to this endpoint when organization is approved for Bank"
        key :required, true
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :name
        key :in, :query
        key :description, "(optional) The user's full name"
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :email
        key :in, :query
        key :description, "(optional) The user's email address"
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :phone
        key :in, :query
        key :description, "(optional) The user's phone number"
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :address
        key :in, :query
        key :description, "(optional) The user's address"
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :birthdate
        key :in, :query
        key :description, "(optional) The user's birthdate"
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :organizationName
        key :in, :query
        key :description, "(optional) The organization's name"
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :organizationUrl
        key :in, :query
        key :description, "(optional) The organization's website url"
        key :required, false
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, "Take user to html page(s) on Bank Connect"
        content :"text/html" do
          key :example, "<html><!-- Bank Connect HTML --></html>"
        end
      end

      response 200 do
        key :description, "Parse this data in order to redirect the user through Bank Connect"
        content :"application/json" do
          key :example, {
            data: [
              {
                organizationIdentifier: "org_1234",
                status: "pending",
                redirectUrl: "http://yoursite.com/redirect/to",
                connectUrl: "https://bank.hackclub.com/api/v1/connect/continue/axOudk"
              }
            ]
          }
        end
      end

      response 302 do
        key :description, "Following completion of html page, Bank Connect redirects to the redirectUrl you specified"
        content :"url" do
          key :example, "${redirectUrl}?organizationIdentifier=${organizationIdentifier}&status=pending|approved"
        end
      end
    end
  end

  swagger_path "/api/v1/connect/webhook" do
    operation :post do
      key :summary, "Receive webhook payload from Bank Connect"
      key :description, "Receive webhook payload from Bank Connect"
      key :tags, ["Connect"]
      key :operationId, "v1ConnectWebhook"

      response 200 do
        key :description, "Parse this data in order to update the user's Bank Connect status"
        content :"application/json" do
          key :example, {
            data: [
              {
                organizationIdentifier: "org_1234",
                status: "approved"
              }
            ]
          }
        end
      end
    end
  end
end
