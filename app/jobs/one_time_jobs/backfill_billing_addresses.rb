# frozen_string_literal: true

module OneTimeJobs
  class BackfillBillingAddresses < ApplicationJob
    queue_as :default

    def perform
      cardholders_without_billing_address.each do |cardholder|
        update_cardholder_billing_address(cardholder)
      end
    end

    private

    def cardholders_without_billing_address
      StripeCardholder.where(stripe_billing_address_line1: nil, stripe_billing_address_city: nil, stripe_billing_address_country: nil)
    end

    def update_cardholder_billing_address(cardholder)
      cardholder.update!(
        stripe_billing_address_line1: "8605 Santa Monica Blvd #86294",
        stripe_billing_address_city: "West Hollywood",
        stripe_billing_address_state: "CA",
        stripe_billing_address_postal_code: "90069",
        stripe_billing_address_country: "United States"
      )
    end

  end
end
