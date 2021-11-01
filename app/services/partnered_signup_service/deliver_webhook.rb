# frozen_string_literal: true

module PartneredSignupService
  class DeliverWebhook
    TYPE = "partnered_signup.status"

    def initialize(partnered_signup_id:)
      @partnered_signup_id = partnered_signup_id
    end

    def run
      ::ApiService::V1::DeliverWebhook.new(
        type: TYPE,
        webhook_url: webhook_url,
        body: body,
        secret: partner.api_key
      ).run
    end

    private

    def sup
      @partnered_signup ||= PartneredSignup.find(@partnered_signup_id)
    end

    def partner
      sup.partner
    end

    def webhook_url
      partner.webhook_url
    end

    def body
      ::Api::V1::PartneredSignupSerializer.new(partnered_signup: sup).run.to_json
    end
  end
end
