# frozen_string_literal: true

class ConnectV1Documentation < ApplicationDocumentation
  swagger_path "/api/connect/v1/start" do
    operation :get do
      key :summary, "GET v1"
      key :description, "Send user to Bank Connect flow"
      key :tags, ["connect"]
      key :operationId, "connectV1Start"

      parameter do
        key :name, :uniqueIdentifier
        key :in, :query
        key :description, "Uniquely identify the person/organization applying through Bank Connect"
        key :required, true
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :redirectUrl
        key :in, :query
        key :description, "Bank Connect redirects to this page after the user finishes completing Bank Connect."
        key :required, true
        schema do
          key :type, :string
        end
      end
      
      parameter do
        key :name, :name
        key :in, :query
        key :description, ""
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :email
        key :in, :query
        key :description, ""
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :phone
        key :in, :query
        key :description, ""
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :address
        key :in, :query
        key :description, ""
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :birthdate
        key :in, :query
        key :description, ""
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :organizationName
        key :in, :query
        key :description, ""
        key :required, false
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :organizationUrl
        key :in, :query
        key :description, ""
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

      response 302 do
        key :description, "Following completion of html page, Bank Connect redirects to the redirectUrl you specified"
        content :"text/html" do
          key :example, "${redirectUrl}?uniqueIdentifier=${uniqueBankIdentifier}&status=started|pendingApproval|approved"
        end
      end
    end
  end
end
