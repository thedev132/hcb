# frozen_string_literal: true

class V1OrganizationsDocumentation < ApplicationDocumentation
  swagger_path "/api/v1/organizations" do
    operation :get do
      key :summary, "Return information on all your organizations"
      key :description, "Return information on all your organizations"
      key :tags, ["Organizations"]
      key :operationId, "v1Organizations"

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data: [
              {
                organizationIdentifier: "org_1234",
                status: "approved"
              },
              {
                organizationIdentifier: "org_4567",
                status: "pending"
              }
            ]
          }
        end
      end
    end
  end

  swagger_path "/api/v1/organizations/{organizationIdentifier}" do
    operation :get do
      key :summary, "Return information on single organization"
      key :description, "Return information on single organization"
      key :tags, ["Organizations"]
      key :operationId, "v1OrganizationsShow"

      parameter do
        key :name, :organizationIdentifier
        key :in, :path
        key :description, "Identifier of an organization"
        key :required, true
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, ""
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

  swagger_path "/api/v1/organizations/{organizationIdentifier}/generateLoginUrl" do
    operation :get do
      key :summary, "Generate an automatic login url for an organization"
      key :description, "Generate an automatic login url for an organization"
      key :tags, ["Organizations"]
      key :operationId, "v1OrganizationsGenerateLoginUrl"

      parameter do
        key :name, :organizationIdentifier
        key :in, :path
        key :description, "Identifier of an organization"
        key :required, true
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data: [
              {
                organizationIdentifier: "org_1234",
                loginUrl: "http://bank.hackclub.com/api/v1/login?loginToken=tok_1234"
              }
            ]
          }
        end
      end
    end
  end


end
