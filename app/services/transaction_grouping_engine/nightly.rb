# frozen_string_literal: true

module TransactionGroupingEngine
  class Nightly
    include ::TransactionEngine::Shared

    def initialize(start_date: nil)
      @start_date = start_date || last_1_month
    end

    def run
      canonical_transaction_missing_hcb_count = 0
      canonical_transactions.find_each(batch_size: 100) do |ct|
        hcb_code = ::TransactionGroupingEngine::Calculate::HcbCode.new(canonical_transaction_or_canonical_pending_transaction: ct).run

        ct.update_column(:hcb_code, hcb_code)

        HcbCode.find_or_create_by!(hcb_code: hcb_code)

        canonical_transaction_missing_hcb_count += 1
      end
      Ahoy::Event.create!({
                            name: "canonicalTransactionMissingHcbCount",
                            properties: { count: canonical_transaction_missing_hcb_count }
                          })


      canonical_pending_transaction_missing_hcb_count = 0
      canonical_pending_transactions.find_each(batch_size: 100) do |cpt|
        hcb_code = ::TransactionGroupingEngine::Calculate::HcbCode.new(canonical_transaction_or_canonical_pending_transaction: cpt).run

        cpt.update_column(:hcb_code, hcb_code)

        HcbCode.find_or_create_by!(hcb_code: hcb_code)

        canonical_pending_transaction_missing_hcb_count += 1
      end
      Ahoy::Event.create!({
                            name: "pendingTransactionMissingHcbCount",
                            properties: { count: canonical_pending_transaction_missing_hcb_count }
                          })

    end

    private

    def canonical_transactions
      CanonicalTransaction.missing_or_unknown_hcb_code.where("date >= ?", @start_date)
    end

    def canonical_pending_transactions
      CanonicalPendingTransaction.missing_or_unknown_hcb_code
    end

  end
end
