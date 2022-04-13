# frozen_string_literal: true

module TransactionGroupingEngine
  module Transaction
    class AssociationPreloader
      def initialize(transactions:)
        @transactions = transactions
      end

      def run!
        preload_associations!
      end

      def preload_associations!
        canonical_transaction_ids = @transactions.flat_map(&:canonical_transaction_ids)
        canonical_transactions_by_id = CanonicalTransaction.where(id: canonical_transaction_ids).index_by(&:id)

        hcb_code_codes = @transactions.map(&:hcb_code)
        hcb_code_objects = HcbCode.where(hcb_code: hcb_code_codes)
        hcb_code_by_code = hcb_code_objects.index_by(&:hcb_code)

        @transactions.each do |t|
          t.canonical_transactions = canonical_transactions_by_id.slice(*t.canonical_transaction_ids)
                                                                 .values
                                                                 .sort do |ct1, ct2|
                                                                   # date in descending order
                                                                   if ct2.date > ct1.date
                                                                     1
                                                                   elsif ct2.date < ct1.date
                                                                     -1
                                                                   else
                                                                     # if dates are equal, id in descending order
                                                                     ct2.id <=> ct1.id
                                                                   end
                                                                 end

          t.local_hcb_code = hcb_code_by_code[t.hcb_code]
        end
      end

    end
  end
end
