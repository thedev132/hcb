module TransactionEngine
  module FriendlyMemoService
    class Generate
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        friendly_memo = handle_hack_club_bank_fee || 
          handle_linked_object || 
          handle_emburse_refund || 
          handle_solely_from_memo

        friendly_memo.to_s.upcase
      end

      private

      def handle_hack_club_bank_fee
        return "HACK CLUB BANK FEE" if hack_club_fee?
      end

      def handle_linked_object
        case linked_object.class.to_s
        when "Disbursement"
          linked_object.name.to_s.upcase
        when "Invoice"
          linked_object.sponsor.name.to_s.upcase
        else
          nil
        end
      end

      def handle_emburse_refund
        return (raw_emburse_transaction.bank_account_description || raw_emburse_transaction.merchant_description).to_s.upcase if amount_cents > 0 && raw_emburse_transaction.present?
      end

      def handle_deprecated_linked_object
        case deprecated_linked_object.class.to_s
        when "Transaction"
          deprecated_linked_object.display_name.to_s.upcase
        else
          nil
        end
      end

      def handle_solely_from_memo
        @smart_memo ||= ::TransactionEngine::FriendlyMemoService::GenerateSolelyFromMemo.new(canonical_transaction: @canonical_transaction).run
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def linked_object
        @canonical_transaction.linked_object
      end

      def deprecated_linked_object
        @canonical_transaction.deprecated_linked_object
      end

      def raw_emburse_transaction
        @canonical_transaction.raw_emburse_transaction
      end

      def hack_club_fee?
        @canonical_transaction.fees.hack_club_fee.exists?
      end
    end
  end
end

