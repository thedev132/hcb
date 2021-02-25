module Temp
  module SyncReceipts
    class Nightly
      def run
        # StripeAuthorizations
        Receipt.where(receiptable_type: "StripeAuthorization").find_each(batch_size: 100) do |receipt|
          raw_stripe_transaction = identify_raw_stripe_transaction(stripe_authorization_id: receipt.receiptable.stripe_id)
          next unless raw_stripe_transaction

          canonical_transaction = identify_canonical_transaction(obj: raw_stripe_transaction)
          next unless canonical_transaction
          next if canonical_transaction.receipts.present? # skip if already has a receipt set

          create_receipt!(receipt: receipt, canonical_transaction: canonical_transaction)
        end

        # EmburseTransactions
        Receipt.where(receiptable_type: "EmburseTransaction").find_each(batch_size: 100) do |receipt|
          raw_emburse_transaction = identify_raw_emburse_transaction(emburse_id: receipt.receiptable.emburse_id)
          next unless raw_emburse_transaction

          canonical_transaction = identify_canonical_transaction(obj: raw_emburse_transaction)
          next unless canonical_transaction
          next if canonical_transaction.receipts.present? # skip if already has a receipt set

          create_receipt!(receipt: receipt, canonical_transaction: canonical_transaction)
        end

        # Transactions
        Receipt.where(receiptable_type: "Transaction").find_each(batch_size: 100) do |receipt|
          raise NotImplementedError, "Syncing transaction receipts not yet codified"
        end
      end

      private

      def identify_raw_stripe_transaction(stripe_authorization_id:)
        raw_stripe_transaction = RawStripeTransaction.where("stripe_transaction->>'authorization' = '#{stripe_authorization_id}'").first

        return nil unless raw_stripe_transaction

        Airbrake.notify("There was more than 1 hashed transaction for raw_stripe_transaction: #{raw_stripe_transaction.id}") if raw_stripe_transaction.hashed_transactions.length > 1

        raw_stripe_transaction
      end

      def identify_raw_emburse_transaction(emburse_id:)
        raw_emburse_transaction = RawEmburseTransaction.where(emburse_transaction_id: emburse_id).first

        return nil unless raw_emburse_transaction

        Airbrake.notify("There was more than 1 hashed transaction for raw_emburse_transaction: #{raw_emburse_transaction.id}") if raw_emburse_transaction.hashed_transactions.length > 1

        raw_emburse_transaction
      end

      def identify_canonical_transaction(obj:)
        obj.hashed_transactions.first.try(:canonical_transaction)
      end

      def create_receipt!(receipt:, canonical_transaction:)
        attrs = {
          user_id: receipt.user_id,
          created_at: receipt.created_at,
          receiptable_type: 'CanonicalTransaction',
          receiptable_id: canonical_transaction.id,
          file: receipt.file.blob
        }
        Receipt.create!(attrs)
      end
    end
  end
end
