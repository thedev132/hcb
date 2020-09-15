module HashedTransactionService
  module RawPlaidTransaction
    class Import
      def run
        ::RawPlaidTransaction.find_each do |pt|
          attrs = {
            primary_hash: primary_hash(pt),
            plaid_transaction_id: pt.id
          }
          ::HashedTransaction.find_or_initialize_by(attrs).tap do |ht|
            # set other details here
          end.save!
        end
      end

      private

      def primary_hash(pt)
        attrs = {
          date: pt.date_posted.strftime('%Y-%m-%d'),
          amount_cents: pt.amount_cents,
          memo: pt.plaid_transaction['name'].upcase
        }
        ::HashedTransactionService::PrimaryHash.new(attrs).run
      end
    end
  end
end
