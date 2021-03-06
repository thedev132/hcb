module Temp
  module SyncCustomMemos
    class Nightly
      def run
        Transaction.renamed.find_each(batch_size: 100) do |t|
          next unless t.display_name

          rpt = RawPlaidTransaction.where(plaid_transaction_id: t.plaid_id).first
          
          next unless rpt # it's possible that the raw plaid transaction is not yet imported because it's a separate process

          rpt.hashed_transactions.each do |ht|
            ct = ht.canonical_transaction

            next unless ct
            next if ct.custom_memo.present?

            ::CanonicalTransactionService::SetCustomMemo.new(canonical_transaction_id: ct.id, custom_memo: t.display_name.upcase) if t.display_name.present?
          end
        end

        StripeAuthorization.renamed.find_each(batch_size: 100) do |sa|
          next unless sa.display_name

          rst = RawStripeTransaction.where(stripe_transaction_id: sa.stripe_id).first

          next unless rst

          rst.hashed_transactions.each do |ht|
            ct = ht.canonical_transaction

            next unless ct
            next if ct.custom_memo.present?

            ::CanonicalTransactionService::SetCustomMemo.new(canonical_transaction_id: ct.id, custom_memo: sa.display_name.upcase) if sa.display_name.present?
          end
        end
      end

    end
  end
end
