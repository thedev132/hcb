# frozen_string_literal: true

module InvoiceService
  class Create
    def initialize(event_id:,
                   due_date:, item_description:, item_amount:,
                   current_user:,
                   sponsor_id:,
                   sponsor_name:, sponsor_email:,
                   sponsor_address_line1:, sponsor_address_line2:,
                   sponsor_address_city:, sponsor_address_state:,
                   sponsor_address_postal_code:)
      @event_id = event_id

      @due_date = due_date
      @item_description = item_description
      @item_amount = item_amount

      @current_user = current_user

      @sponsor_id = sponsor_id
      @sponsor_name = sponsor_name
      @sponsor_email = sponsor_email
      @sponsor_address_line1 = sponsor_address_line1
      @sponsor_address_line2 = sponsor_address_line2
      @sponsor_address_city = sponsor_address_city
      @sponsor_address_state = sponsor_address_state
      @sponsor_address_postal_code = sponsor_address_postal_code
    end

    def run
      invoice = nil

      ActiveRecord::Base.transaction do
        sponsor
        invoice = Invoice.create!(attrs)
      end

      invoice
    end

    private

    def attrs
      {
        due_date: @due_date,
        item_description: @item_description,
        item_amount: cleanse(@item_amount),
        sponsor: sponsor,
        creator: @current_user
      }
    end

    def sponsor_attrs
      {
        name: @sponsor_name,
        contact_email: @sponsor_email,
        address_line1: @sponsor_address_line1,
        address_line2: @sponsor_address_line2,
        address_city: @sponsor_address_city,
        address_state: @sponsor_address_state,
        address_postal_code: @sponsor_address_postal_code
      }
    end

    def sponsor
      @sponsor ||= begin
        if existing_sponsor
          existing_sponsor.update!(sponsor_attrs)
          existing_sponsor
        else
          event.sponsors.create!(sponsor_attrs)
        end
      end
    end

    def existing_sponsor
      @existing_sponsor ||= event.sponsors.find_by(id: @sponsor_id) || event.sponsors.not_null_slugs.find_by(slug: @sponsor_id)
    end

    def event
      @event ||= Event.friendly.find(@event_id)
    end

    def cleanse(item_amount)
      @item_amount.gsub(",", "").to_f * 100.to_i
    end
  end
end
