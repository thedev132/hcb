# frozen_string_literal: true

module TransactionGroupingEngine
  class Nightly
    include ::TransactionEngine::Shared

    def initialize(start_date: nil)
      @start_date = start_date || last_1_month
    end

    def run
      canonical_transactions.find_each(batch_size: 100) do |ct|
        hcb_code = ::TransactionGroupingEngine::Calculate::HcbCode.new(canonical_transaction: ct).run

        ct.update_column(:hcb_code, hcb_code)
      end
    end

    private

    def canonical_transactions
      CanonicalTransaction.missing_hcb_code.where("date >= ?", @start_date)
    end

  end
end
