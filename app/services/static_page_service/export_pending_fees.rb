require "csv"

module StaticPageService
  class ExportPendingFees
    include ::Shared::Fee::CanonicalFeeMemo

    def run
      CSV.generate(headers: true) do |csv|
        csv << attributes

        Event.pending_fees.find_each do |event|
          csv << [(event.fee_balance / 100.0), canonical_fee_memo(event: event)]
        end
      end
    end

    private

    def attributes
      [
        "amount",
        "transaction_memo"
      ]
    end
  end
end
