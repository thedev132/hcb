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
        canonical_transactions = CanonicalTransaction.where(id: canonical_transaction_ids)
        canonical_transactions_by_id = canonical_transactions.index_by(&:id)

        hcb_code_codes = @transactions.map(&:hcb_code)
        hcb_code_objects = HcbCode.where(hcb_code: hcb_code_codes)
        hcb_code_by_code = hcb_code_objects.index_by(&:hcb_code)

        # query again for CanonicalTransactions associated with these hcb_codes, since this set could be greater than
        # the canonical_transactions we got from the current page
        canonical_transactions_by_hcb_code = CanonicalTransaction.where(hcb_code: hcb_code_codes).group_by(&:hcb_code)

        hcb_code_objects.each do |hc|
          hc.canonical_transactions = canonical_transactions_by_hcb_code[hc.hcb_code]
                                      .sort { |ct1, ct2| compare_date_id_descending(ct1, ct2) }
        end

        hack_club_fees_by_canonical_transaction_id = Fee
                                                     .includes(:canonical_event_mapping)
                                                     .where(canonical_event_mappings: { canonical_transaction_id: canonical_transaction_ids })
                                                     .hack_club_fee
                                                     .index_by { |fee| fee.canonical_event_mapping.canonical_transaction_id }

        canonical_transactions.each do |ct|
          ct.fee_payment = hack_club_fees_by_canonical_transaction_id[ct.id].present?
        end

        @transactions.each do |t|
          t.canonical_transactions = canonical_transactions_by_id
                                     .slice(*t.canonical_transaction_ids)
                                     .values
                                     .sort { |ct1, ct2| compare_date_id_descending(ct1, ct2) }

          t.local_hcb_code = hcb_code_by_code[t.hcb_code]
        end
      end

      # comparator that can be used in Array#sort for canonical_transactions
      # https://ruby-doc.org/core-2.7.5/Array.html#method-i-sort
      def compare_date_id_descending(ct1, ct2)
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

    end
  end
end
