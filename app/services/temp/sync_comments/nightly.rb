module Temp
  module SyncComments
    class Nightly
      def run
        ["Transaction", "LoadCardRequest", "Invoice", "GSuiteApplication", "GSuite", "FeeReimbursement", "OrganizerPositionDeletionRequest", "AchTransfer", "Check", "EmburseTransaction", "EmburseCardRequest", "EmburseTransfer", "Donation", "StripeAuthorization"]

        # StripeAuthorizations
        Comment.where(commentable_type: "StripeAuthorization").find_each do |comment|
          raw_stripe_transaction = identify_raw_stripe_transaction(stripe_authorization_id: comment.commentable.stripe_id)
          next unless raw_stripe_transaction

          canonical_transaction = identify_canonical_transaction(obj: raw_stripe_transaction)
          next unless canonical_transaction
          next if canonical_transaction.comments.present? # skip if already has a comment set

          create_comment!(comment: comment, canonical_transaction: canonical_transaction)
        end

        # EmburseTransactions
        Comment.where(commentable_type: "EmburseTransaction").find_each do |comment|
          raw_emburse_transaction = identify_raw_emburse_transaction(emburse_id: comment.commentable.emburse_id)
          next unless raw_emburse_transaction

          canonical_transaction = identify_canonical_transaction(obj: raw_emburse_transaction)
          next unless canonical_transaction
          next if canonical_transaction.comments.present? # skip if already has a comment set

          create_comment!(comment: comment, canonical_transaction: canonical_transaction)
        end

        Comment.where(commentable_type: "Transaction").find_each do |comment|
          raw_plaid_transaction = identify_raw_plaid_transaction(plaid_id: comment.commentable.plaid_id)
          next unless raw_plaid_transaction

          canonical_transaction = identify_canonical_transaction(obj: raw_plaid_transaction)
          next unless canonical_transaction
          next if canonical_transaction.comments.present? # skip if already has a comment set

          create_comment!(comment: comment, canonical_transaction: canonical_transaction)
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

      def identify_raw_plaid_transaction(plaid_id:)
        raw_plaid_transaction = RawPlaidTransaction.where(plaid_transaction_id: plaid_id).first

        return nil unless raw_plaid_transaction

        Airbrake.notify("There was more than 1 hashed transaction for raw_plaid_transaction: #{raw_plaid_transaction.id}") if raw_plaid_transaction.hashed_transactions.length > 1

        raw_plaid_transaction
      end

      def identify_canonical_transaction(obj:)
        obj.hashed_transactions.first.try(:canonical_transaction)
      end

      def create_comment!(comment:, canonical_transaction:)
        attrs = {
          user_id: comment.user_id,
          created_at: comment.created_at,
          commentable_type: 'CanonicalTransaction',
          commentable_id: canonical_transaction.id,
          file: comment.file.blob
        }
        Comment.create!(attrs)
      end
    end
  end
end
