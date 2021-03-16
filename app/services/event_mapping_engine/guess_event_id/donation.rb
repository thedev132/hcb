module EventMappingEngine
  module GuessEventId
    class Donation
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        donation.event.id
      end

      private

      def donation
        @donation ||= donation_payout.donation
      end

      def donation_payout
        @donation_payout ||= DonationPayout.where("amount = #{amount_cents} and statement_descriptor ilike 'DONATE #{prefix}'")
      end

      def prefix
        @prefix ||= memo.upcase.gsub("HACK CLUB BANK DONATE", "")
          .gsub("HACKC DONATE", "").strip.upcase
      end

      def memo
        @memo ||= @canonical_transaction.memo
      end

      def amount_cents
        @amount_cents ||= @canonical_transaction.amount_cents
      end
    end
  end
end
