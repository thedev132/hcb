# frozen_string_literal: true

module OneTimeJobs
  class BackfillMissingCanonicalTransactionCustomMemoJob < ApplicationJob
    def perform
      canonical_transactions_to_copy_memo = CanonicalTransaction.includes(:canonical_pending_transaction).all.filter do |ct|
        ct.custom_memo.nil? &&
          ct.canonical_pending_transaction&.custom_memo&.present? &&
          ct.custom_memo != ct.canonical_pending_transaction.custom_memo
      end

      canonical_transactions_to_copy_memo.each do |ct|
        ct.update(custom_memo: ct.canonical_pending_transaction.custom_memo)
      end
    end

  end
end
