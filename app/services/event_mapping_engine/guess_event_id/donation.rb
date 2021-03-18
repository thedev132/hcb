module EventMappingEngine
  module GuessEventId
    class Donation
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        return nil unless donation

        donation.event.id
      end

      private

      def donation
        @donation ||= donation_payout.try(:donation)
      end

      def donation_payout
        @donation_payout ||= DonationPayout.where("amount = #{amount_cents} and statement_descriptor ilike 'DONATE #{prefix}%' and created_at >= '#{filter_date}'").order("created_at asc").first
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

      def filter_date
        @filter_date ||= (@canonical_transaction.date - 5.days).strftime("%Y-%m-%d")
      end
    end
  end
end
