module HashedTransactionService
  module RawEmburseTransaction
    class Import
      def run
        ::RawEmburseTransaction.find_each do |et|
          next if et.amount_cents == 0

          ph = primary_hash(et)

          attrs = {
            primary_hash: ph[0],
            raw_emburse_transaction_id: et.id
          }
          ::HashedTransaction.find_or_initialize_by(attrs).tap do |ht|
            ht.primary_hash_input = ph[1]
          end.save!
        end
      end

      private

      def primary_hash(et)
        attrs = {
          date: et.date_posted.strftime('%Y-%m-%d'),
          amount_cents: et.amount_cents,
          memo: memo(et)
        }

        ::HashedTransactionService::PrimaryHash.new(attrs).run
      end

      def memo(et)
        if et.amount_cents < 0
          "#{et.emburse_transaction.dig('merchant', 'name')}, Card: #{et.emburse_transaction.dig('card', 'description')}, Member: #{et.emburse_transaction.dig('member', 'first_name')} #{et.emburse_transaction.dig('member', 'last_name')}".upcase
        else
          "Transfer from #{et.emburse_transaction.dig('bank_account', 'description')}".upcase
        end
      end
    end
  end
end
