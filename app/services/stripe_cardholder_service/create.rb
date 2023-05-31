# frozen_string_literal: true

module StripeCardholderService
  class Create
    def initialize(current_user:, current_session:, event_id:)
      @current_user = current_user
      @current_session = current_session
      @event_id = event_id
    end

    def run
      raise ArgumentError, "not permitted under spend only plan" if event.unapproved?

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
        # stripe_billing_address_line2: line2,
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
            # line2: line2,
            city: city,
            state: state,
            postal_code: postal_code,
            country: country
          }
        },
        individual: {
          first_name: first_name,
          last_name: last_name,
          dob: dob,
          card_issuing: {
            user_terms_acceptance: {
              date: DateTime.now.to_i,
              ip: @current_session.ip
            }
          }
        }
      }
    end

    def first_name
      clean_name(@current_user.first_name)
    end

    def last_name
      clean_name(@current_user.last_name)
    end

    def clean_name(name)
      name = ActiveSupport::Inflector.transliterate(name || "")

      # Remove invalid characters
      requirements = <<~REQ.squish
        First and Last names must contain at least 1 letter, and may not
        contain any numbers, non-latin letters, or special characters except
        periods, commas, hyphens, spaces, and apostrophes.
      REQ
      name = name.gsub(/[^a-zA-Z.,\-\s']/, "").strip
      raise ArgumentError, requirements if name.gsub(/[^a-z]/i, "").blank?

      name
    end

    def dob
      return nil unless @current_user.birthday
      # We don't want to share the dob for users under 13
      # https://github.com/hackclub/bank/pull/3071#issuecomment-1268880804
      return nil if @current_user.birthday > 13.years.ago

      {
        day: @current_user.birthday.day,
        month: @current_user.birthday.month,
        year: @current_user.birthday.year
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
