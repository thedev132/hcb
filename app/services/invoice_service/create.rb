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

        item = StripeService::InvoiceItem.create(remote_invoice_item_attrs)
        remote_invoice = StripeService::Invoice.create(remote_invoice_attrs(invoice: invoice))

        invoice.item_stripe_id = item.id
        invoice.stripe_invoice_id = remote_invoice.id
        invoice.save!

        remote_invoice.send_invoice

        attrs = {
          invoice_id: invoice.id
        }
        ::InvoiceService::SyncRemoteToLocal.new(attrs).run
      end

      invoice
    end

    private

    def remote_invoice_item_attrs
      {
        customer: sponsor.stripe_customer_id,
        currency: "usd",
        description: @item_description,
        amount: clean_item_amount
      }
    end

    def remote_invoice_attrs(invoice:)
      {
        customer: sponsor.stripe_customer_id,
        auto_advance: invoice.auto_advance,
        billing: "send_invoice",
        due_date: invoice.due_date.to_i, # convert to unixtime
        description: invoice.memo,
        status: invoice.status,
        statement_descriptor: invoice.statement_descriptor || "HACK CLUB BANK",
        tax_percent: invoice.tax_percent,
        footer: footer
      }
    end

    def footer
      "\n\n\n\n\n"\
        "Need to pay by mailed paper check?\n\n"\
        "Please pay the amount to the order of The Hack Foundation, and include '#{sponsor.event.name} (##{sponsor.event.id})' in the memo. Checks can be mailed to:\n\n"\
        "#{sponsor.event.name} (##{sponsor.event.id}) c/o The Hack Foundation\n"\
        "8605 Santa Monica Blvd #86294\n"\
        "West Hollywood, CA 90069"
    end

    def attrs
      {
        due_date: @due_date,
        item_description: @item_description,
        item_amount: clean_item_amount,
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

    def clean_item_amount
      @clean_item_amount ||= cleanse(@item_amount)
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
      (@item_amount.gsub(",", "").to_f * 100.to_i).to_i
    end
  end
end
