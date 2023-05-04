# frozen_string_literal: true

module OneTimeJobs
  class SetTransactionSource
    def run
      CanonicalTransaction.includes(hashed_transactions: [:raw_csv_transaction, :raw_plaid_transaction, :raw_emburse_transaction, :raw_stripe_transaction, :raw_increase_transaction]).where(transaction_source: nil).find_each(batch_size: 100) do |canonical_transaction|
        ht = canonical_transaction.hashed_transactions.first

        canonical_transaction.update!(
          transaction_source: ht.raw_csv_transaction || ht.raw_plaid_transaction || ht.raw_emburse_transaction || ht.raw_stripe_transaction || ht.raw_increase_transaction,
        )
      end
    end

  end
end
