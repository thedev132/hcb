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

      parameter do
        key :name, :email
        key :in, :query
        key :description, "Email address of the user setting up the Hack Club Bank account"
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
              owner_email: nil,
              organization_name: "My Organization's Name",
              organization_id: nil
            },
            links: {
              self: "https://api.hackclub.com/v2/partnered_signups/sup_l3mtZz"
            }
          }
        end
      end
    end
  end

  swagger_path "https://yoursite.com/api/bankConnect/webhook" do
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
              owner_email: "user@gmail.com",
              organization_name: "My Organization's Name",
              organization_id: nil
            },
            links: {
              self: "https://api.hackclub.com/v2/partnered_signups/sup_l3mtZz"
            },
            meta: {
              type: "partnered_signup.status"
            }
          }
        end
      end
    end
  end

  swagger_path "/api/v2/partnered_signups" do
    operation :get do
      key :summary, "Return information on all your PartneredSignups"
      key :description, "Return information on all your PartneredSignups"
      key :tags, ["Bank Connect (PartneredSignups)"]
      key :operationId, "v2PartneredSignups"

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data: [
              {
                id: "sup_lYntM4",
                status: "accepted",
                redirect_url: "https://yoursite.com/organizations/5154/bankConnect/redirect",
                connect_url: "https://bank.hackclub.com/api/v2/connect/continue/sup_lYntM4",
                owner_email: "hey@gmail.com",
                organization_name: "Test org",
                organization_id: "org_BJouPR"
              },
              {
                id: "sup_l3mtZz",
                status: "submitted",
                redirect_url: "https://yoursite.com/organizations/1234/bankConnect/redirect",
                connect_url: "https://bank.hackclub.com/api/v2/connect/continue/sup_l3mtZz",
                owner_email: "user@gmail.com",
                organization_name: "My Organization's Name",
                organization_id: nil
              },
            ]
          }
        end
      end
    end
  end

  swagger_path "/api/v2/partnered_signup/{partnered_signups_id}" do
    operation :get do
      key :summary, "Return information on single PartneredSignup"
      key :description, "Return information on single PartneredSignup"
      key :tags, ["Bank Connect (PartneredSignups)"]
      key :operationId, "v2PartneredSignupShow"

      parameter do
        key :name, :partnered_signups_id
        key :in, :path
        key :description, "Bank Connect's `partnered_signups_id`"
        key :required, true
        schema do
          key :type, :string
        end
      end

      response 200 do
        key :description, ""
        content :"application/json" do
          key :example, {
            data: {
              id: "sup_l3mtZz",
              status: "submitted",
              redirect_url: "https://yoursite.com/organizations/1234/bankConnect/redirect",
              connect_url: "https://bank.hackclub.com/api/v2/connect/continue/sup_l3mtZz",
              owner_email: "user@gmail.com",
              organization_name: "My Organization's Name",
              organization_id: nil
            },
            links: {
              self: "https://api.hackclub.com/v2/partnered_signups/sup_l3mtZz"
            }
          }
        end
      end
    end
  end
end
