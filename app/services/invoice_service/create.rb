module InvoiceService
  class Create
    def initialize(event_id:, sponsor_id:,
                   due_date:, item_description:, item_amount:,
                   current_user:)
      @event_id = event_id
      @sponsor_id = sponsor_id

      @due_date = due_date
      @item_description = item_description
      @item_amount = item_amount

      @current_user = current_user
    end

    def run
      invoice = nil

      ActiveRecord::Base.transaction do
        invoice = event.invoices.create!(attrs)
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

    def sponsor
      @sponsor ||= event.sponsors.find_by(id: @sponsor_id)
    end

    def event
      @event ||= Event.friendly.find(@event_id)
    end

    def cleanse(item_amount)
      @item_amount.gsub(",", "").to_f * 100.to_i
    end
  end
end
