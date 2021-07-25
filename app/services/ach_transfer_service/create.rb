# frozen_string_literal: true

module AchTransferService
  class Create
    include ::Shared::AmpleBalance

    def initialize(event_id:,
                   routing_number:, account_number:, bank_name:, recipient_name:, recipient_tel:, amount_cents:, payment_for:,
                   current_user:)
      @event_id = event_id

      @routing_number = routing_number
      @account_number = account_number
      @bank_name = bank_name
      @recipient_name = recipient_name
      @recipient_tel = recipient_tel
      @amount_cents = amount_cents
      @payment_for = payment_for

      @current_user = current_user
    end

    def run
      raise ArgumentError, "You don't have enough money to send this transfer." unless ample_balance?

      AchTransfer.create!(create_attrs)
    end

    private

    def create_attrs
      {
        event: event,

        routing_number: @routing_number,
        account_number: @account_number,
        bank_name: @bank_name,
        recipient_name: @recipient_name,
        recipient_tel: @recipient_tel,
        amount: @amount_cents,
        payment_for: @payment_for,

        creator: @current_user
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end
  end
end
