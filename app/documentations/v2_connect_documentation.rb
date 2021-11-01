# frozen_string_literal: true

class V2ConnectDocumentation < ApplicationDocumentation
  swagger_path "/api/v2/connect/start" do
    operation :post do
      key :summary, "Start the Bank Connect flow"
      key :description, "Creates a **PartneredSignup** object which is used to track the onboarding and application progress"
      key :tags, ["Bank Connect (PartneredSignups)"]
      key :operationId, "v2ConnectStart"

      parameter do
        key :name, :organization_name
        key :in, :query
        key :description, "The organization's name"
        key :required, true
        schema do
          key :type, :string
        end
      end

      parameter do
        key :name, :redirect_url
        key :in, :query
        key :description, "Bank Connect redirects to this page after the user finishes the Bank Connect flow"
        key :required, true
        schema do
          key :type, :string
        end
      end

      # parameter do
      #   key :name, :organizationIdentifier
      #   key :in, :query
      #   key :description, "Uniquely identify the organization applying through Bank Connect"
      #   key :required, true
      #   schema do
      #     key :type, :string
      #   end
      # end

      # parameter do
      #   key :name, :name
      #   key :in, :query
      #   key :description, "(optional) The user's full name"
      #   key :required, false
      #   schema do
      #     key :type, :string
      #   end
      # end

      # parameter do
      #   key :name, :email
      #   key :in, :query
      #   key :description, "(optional) The user's email address"
      #   key :required, false
      #   schema do
      #     key :type, :string
      #   end
      # end

      # parameter do
      #   key :name, :phone
      #   key :in, :query
      #   key :description, "(optional) The user's phone number"
      #   key :required, false
      #   schema do
      #     key :type, :string
      #   end
      # end

      # parameter do
      #   key :name, :address
      #   key :in, :query
      #   key :description, "(optional) The user's address"
      #   key :required, false
      #   schema do
      #     key :type, :string
      #   end
      # end

      # parameter do
      #   key :name, :birthdate
      #   key :in, :query
      #   key :description, "(optional) The user's birthdate"
      #   key :required, false
      #   schema do
      #     key :type, :string
      #   end
      # end

      # parameter do
      #   key :name, :organizationUrl
      #   key :in, :query
      #   key :description, "(optional) The organization's website url"
      #   key :required, false
      #   schema do
      #     key :type, :string
      #   end
      # end

      # response 200 do
      #   key :description, "Take user to html page(s) on Bank Connect"
      #   content :"text/html" do
      #     key :example, "<html><!-- Bank Connect HTML --></html>"
      #   end
      # end

      response 200 do
        key :description, "Redirect the user to `connect_url` in order to continue the user through the Bank Connect flow. " \
                          "They will be greeted by a form.\n\nOnce the user fills out the \"Bank Connect Form\", they will be " \
                          "redirected to the `redirect_url`."
        content :"application/json" do
          key :example, {
            data: {
              id: "sup_l3mtZz",
              status: "unsubmitted",
              redirect_url: "https://yoursite.com/organizations/1234/bankConnect/redirect",
              connect_url: "https://bank.hackclub.com/api/v2/connect/continue/sup_l3mtZz",
              owner_phone: nil,
              owner_email: nil,
              owner_name: nil,
              owner_address: nil,
              owner_birthdate: nil,
              country: nil,
              organization_name: "My Organization's Name",
              organization_id: nil
            }
          }
        end
      end
    end
  end

  swagger_path "yoursite.com/api/bankConnect/webhook" do
    operation :post do
      key :summary, "Receive webhook payload from Bank Connect to your site"
      key :description, "Receive **webhook payload** from Bank Connect.\n\n" \
                        "Webhooks from Bank Connect can be verified using [Stripe's webhook signature system](https://stripe.com/docs/webhooks/signatures). " \
                        "The verification signature is located in the `HCB-Signature` header and the `secret` is your Bank Connect api key."
      key :tags, ["Bank Connect (PartneredSignups)"]
      key :operationId, "v2ConnectWebhook"

      response 200 do
        key :description, "Parse this **PartneredSignup** object in order to update the organization's Bank Connect `status` in your database (in this example, it is 'submitted', " \
                          "indicating that the user has submitted the Bank Connect Form.\n\nAfter a user has submit the Bank Connect Form (`status` = 'submitted'), " \
                          "it will be reviewed by the Hack Club Bank team — resulting in either an approval or rejection.\n\n Once an **PartneredSignup** has been " \
                          "approved, the `organization_id` will no longer be 'null' (such as 'org_s2cDsp'). Alternatively, a rejected **PartneredSignup** will have a 'rejected' `status` " \
                          "and the `organization_id` will remain 'null'."
        content :"application/json" do
          key :example, {
            data: {
              id: "sup_l3mtZz",
              status: "submitted",
              redirect_url: "https://yoursite.com/organizations/1234/bankConnect/redirect",
              connect_url: "https://bank.hackclub.com/api/v2/connect/continue/sup_l3mtZz",
              owner_phone: "123456789",
              owner_email: "user@gmail.com",
              owner_name: "My Name",
              owner_address: "1 street",
              owner_birthdate: "2021-01-01",
              country: 1,
              organization_name: "My Organization's Name",
              organization_id: nil
            }
          }
        end
      end
    end
  end
end
