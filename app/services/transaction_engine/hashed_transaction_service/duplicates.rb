# frozen_string_literal: true

module TransactionEngine
  module HashedTransactionService
    class Duplicates
      def run
        ::HashedTransaction.where(primary_hash: duplicate_primary_hashes)
      end

      private

      def duplicate_primary_hashes
        @duplicate_primary_hashes ||= ::HashedTransaction.select(:primary_hash).group(:primary_hash).having("count(primary_hash) > 1").pluck(:primary_hash)
      end

    end
  end
end
