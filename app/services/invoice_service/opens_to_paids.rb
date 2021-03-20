# frozen_string_literal: true

module InvoiceService
  class OpensToPaids
    def initialize(since_date: nil)
      @since_date = Time.now.utc - 6.months # only look back last 6 months
    end

    def run
      # 1. iterate over open invoices
      Invoice.open.where("created_at >= ?", @since_date).each do |i|
        ActiveRecord::Base.connection do
          i.sync_from_remote!

          ::InvoiceService::Queue.new(invoice_id: i.id).run if i.reload.paid?
        end
      end
    end
  end
end
