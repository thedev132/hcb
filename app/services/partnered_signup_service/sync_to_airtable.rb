# frozen_string_literal: true

module PartneredSignupService
  class SyncToAirtable
    PROXY_URL = "https://airtable-forms-proxy.hackclub.dev/api/apppALh5FEOKkhjLR/Partnered%20Signups"

    def initialize(partnered_signup_id:)
      @partnered_signup_id = partnered_signup_id
    end

    def run
      raise ArgumentError, "Partnered Signup #{@partnered_signup_id} is not been submitted" if partnered_signup.unsubmitted?

      res = conn.post(PROXY_URL) do |req|
        req.body = body
      end

      # Airtable Proxy is designed to return a 302 on succeessful submissions
      raise ArgumentError, "Error POSTing to Airtable. HTTP status: #{res.status}" unless res.success? || (res.status >= 300 && res.status < 400)

      res
    end

    private

    # @return [PartneredSignup]
    def partnered_signup
      @partnered_signup ||= PartneredSignup.find(@partnered_signup_id)
    end

    def conn
      @conn ||= Faraday.new(new_attrs)
    end

    def new_attrs
      {
        headers: { "Content-Type" => "application/json" }
      }
    end

    def body
      data = {
        # Partnered Signup
        "Organization Name": partnered_signup.organization_name,
        "Owner Email": partnered_signup.owner_email,
        "Owner Name": partnered_signup.owner_name,
        "Owner Phone": partnered_signup.owner_phone,
        "Owner Birthdate": partnered_signup.owner_birthdate,
        "Address Line 1": partnered_signup.owner_address_line1,
        "Address Line 2": partnered_signup.owner_address_line2,
        "Address City": partnered_signup.owner_address_city,
        "Address State": partnered_signup.owner_address_state,
        "Postal Code": partnered_signup.owner_address_postal_code,
        "Address Country": partnered_signup.owner_address_country,
        "Submitted At": partnered_signup.submitted_at,
        "Partnered Signup ID": partnered_signup.id,

        # Partner
        "Partner": partnered_signup.partner.name,
        "Partner ID": partnered_signup.partner.id,
      }

      data.to_json
    end

  end
end
