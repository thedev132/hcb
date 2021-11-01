# frozen_string_literal: true

class V2OrganizationsDocumentation < ApplicationDocumentation
  swagger_path "/api/v2/organizations" do
    operation :get do
      key :summary, "Return information on all your organizations"
      key :description, "Return information on all your organizations"
      key :tags, ["Organizations"]
      key :operationId, "v2Organizations"

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data: [
              {
                id: "org_Yvguja",
                name: "My Org 1",
                balance: 68605
              },
              {
                id: "org_sKd2vc",
                name: "My Org 2",
                balance: 0
              },
            ]
          }
        end
      end
    end
  end

  swagger_path "/api/v2/organizations/{organization_id}" do
    operation :get do
      key :summary, "Return information on single organization"
      key :description, "`balance` is in cents, similar to Stripe."
      key :tags, ["Organizations"]
      key :operationId, "v2OrganizationsShow"

      parameter do
        key :name, :organization_id
        key :in, :path
        key :description, "Bank Connect's `organization_id`"
        key :required, true
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data:
              {
                id: "org_Yvguja",
                name: "My Org 1",
                balance: 68605
              }
          }
        end
      end
    end
  end

  swagger_path "/api/v2/organizations/{organization_id}/generateLoginUrl" do
    operation :get do
      key :summary, "Generate an automatic login url for an organization"
      key :description, "Redirect a user to this url, and they will be automatically logged into " \
                        "their Hack Club Bank account"
      key :tags, ["Organizations"]
      key :operationId, "v2OrganizationsGenerateLoginUrl"

      parameter do
        key :name, :organization_id
        key :in, :path
        key :description, "Bank Connect's `organization_id`"
        key :required, true
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data:
              {
                organization_id: "org_Yvguja",
                loginUrl: "https://bank.hackclub.com/api/v2/login?loginToken=tok_U2w2vzV2xNNkMFvNGbr9ckqfX7tsKpKh"
              }
          }
        end
      end
    end
  end


end
