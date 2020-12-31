require "csv"

module StaticPageService
  class ExportPendingFees
    def initialize
    end

    def run
      CSV.generate(headers: true) do |csv|
        csv << attributes

        Event.pending_fees.find_each do |event|
          csv << [(event.fee_balance / 100.0), transaction_memo(event)]
        end
      end
    end

    private

    def transaction_memo(event)
      "#{event.id} Hack Club Bank Fee"
    end

    def attributes
      [
        "amount",
        "transaction_memo"
      ]
    end
  end
end
