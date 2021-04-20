# frozen_string_literal: true

module StripeCardholderService
  class Create
    def initialize(current_user:, event_id:)
      @current_user = current_user
      @event_id = event_id
    end

    def run
      raise ArgumentError, "not permitted under spend only plan" if event.is_spend_only

      ActiveRecord::Base.transaction do
        stripe_cardholder = ::StripeCardholder.create!(attrs)

        remote_cardholder = ::StripeService::Issuing::Cardholder.create(remote_attrs)

        stripe_cardholder.update_column(:stripe_id, remote_cardholder.id)

        stripe_cardholder.reload
      end
    end

    private

    def attrs
      {
        user: @current_user,
        stripe_name: name,
        stripe_email: email,
        stripe_phone_number: phone_number,
        stripe_billing_address_line1: line1,
        #stripe_billing_address_line2: line2,
        stripe_billing_address_city: city,
        stripe_billing_address_state: state,
        stripe_billing_address_postal_code: postal_code,
        stripe_billing_address_country: country
      }
    end

    def remote_attrs
      {
        name: name,
        email: email,
        phone_number: phone_number,
        type: cardholder_type,
        billing: {
          address: {
            line1: line1,
            #line2: line2,
            city: city,
            state: state,
            postal_code: postal_code,
            country: country
          }
        }
      }
    end

    def line1
      "8605 Santa Monica Blvd #86294"
    end

    def line2
      nil
    end

    def city
      "West Hollywood"
    end

    def state
      "CA"
    end

    def postal_code
      "90069"
    end

    def country
      "US"
    end

    def email
      @current_user.email
    end

    def phone_number
      @current_user.phone_number
    end

    def name
      @current_user.safe_name
    end

    def cardholder_type
      "individual"
    end

    def event
      @event ||= Event.friendly.find(@event_id)
    end
  end
end
