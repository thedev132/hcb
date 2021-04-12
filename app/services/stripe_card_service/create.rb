# frozen_string_literal: true

module StripeCardService
  class Create
    def initialize(current_user:, event_id:,
                   card_type:,
                   stripe_shipping_name: nil, stripe_shipping_address_city: nil, stripe_shipping_address_state: nil,
                   stripe_shipping_address_line1: nil, stripe_shipping_address_line2: nil, stripe_shipping_address_postal_code: nil)
      @current_user = current_user
      @event_id = event_id

      @card_type = card_type
      @stripe_shipping_name = stripe_shipping_name
      @stripe_shipping_address_city = stripe_shipping_address_city
      @stripe_shipping_address_state = stripe_shipping_address_state
      @stripe_shipping_address_line1 = stripe_shipping_address_line1
      @stripe_shipping_address_line2 = stripe_shipping_address_line2
      @stripe_shipping_address_postal_code = stripe_shipping_address_postal_code
    end

    def run
      raise ArgumentError, "not permitted under spend only plan" if event.is_spend_only

      ActiveRecord::Base.transaction do
        card = event.stripe_cards.create!(attrs)

        remote_stripe_card = create_remote_stripe_card!

        card.stripe_id = remote_stripe_card.id # necessary because of design of sync_from_stripe
        card.sync_from_stripe!
        card.save!
      end
    end

    private

    def attrs
      {
        card_type: @card_type,
        stripe_cardholder_id: stripe_cardholder.id,
        stripe_shipping_name: @stripe_shipping_name,
        stripe_shipping_address_city: @stripe_shipping_address_city,
        stripe_shipping_address_state: @stripe_shipping_address_state,
        stripe_shipping_address_country: "US",
        stripe_shipping_address_line1: @stripe_shipping_address_line1,
        stripe_shipping_address_line2: formatted_stripe_shipping_address_line2,
        stripe_shipping_address_postal_code: @stripe_shipping_address_postal_code
      }.compact
    end

    def formatted_stripe_shipping_address_line2
      @stripe_shipping_address_line2.present? ? @stripe_shipping_address_line2 : nil
    end

    def create_remote_stripe_card!
      ::StripeService::Issuing::Card.create(remote_card_attrs)
    end

    def remote_card_attrs
      attrs = {
        cardholder: stripe_cardholder.stripe_id,
        type: @card_type,
        currency: "usd",
        status: "active"
      }

      if physical?
        attrs[:shipping] = {
          name: @stripe_shipping_name,
          service: "standard",
          address: {
            line1: @stripe_shipping_address_line1,
            line2: formatted_stripe_shipping_address_line2,
            city: @stripe_shipping_address_city,
            state: @stripe_shipping_address_state,
            country: "US",
            postal_code: @stripe_shipping_address_postal_code
          }.compact
        }.compact
      end

      attrs
    end

    def stripe_cardholder
      @stripe_cardholder ||= ::StripeCardholder.find_or_create_by(user: @current_user)
    end

    def event
      @event ||= Event.friendly.find(@event_id)
    end

    def virtual?
      @card_type == "virtual" || @card_type == 0 || @card_type == "0"
    end

    def physical?
      !virtual?
    end
  end
end
