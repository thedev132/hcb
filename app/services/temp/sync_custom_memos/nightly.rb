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

            ct.update_column(:custom_memo, t.display_name.upcase) unless ct.custom_memo.present?
          end
        end

        StripeAuthorization.renamed.find_each(batch_size: 100) do |sa|
          next unless sa.display_name

          rst = RawStripeTransaction.where(stripe_transaction_id: sa.stripe_id).first

          next unless rst

          rst.hashed_transactions.each do |ht|
            ct = ht.canonical_transaction

            next unless ct

            ct.update_column(:custom_memo, sa.display_name.upcase) unless ct.custom_memo.present?
          end
        end
      end

    end
  end
end
