module FeeEngine
  class Hourly
    def run
      CanonicalEventMapping.missing_fee.find_each do |cem|
        reason = determine_reason(cem)

        event_sponsorship_fee = cem.event.sponsorship_fee

        amount_cents_as_decimal = BigDecimal("#{cem.canonical_transaction.amount_cents}") * BigDecimal("#{event_sponsorship_fee}")
        amount_cents_as_decimal = 0 if reason != "REVENUE"

        attrs = {
          canonical_event_mapping_id: cem.id,
          reason: reason,
          amount_cents_as_decimal: amount_cents_as_decimal,
          event_sponsorship_fee: event_sponsorship_fee
        }
        Fee.create!(attrs)
      end
    end

    def determine_reason(cem)
      reason = "TBD"

      # TODO: add other reasons here like disbursements, github, etc
      reason = "HACK CLUB FEE" if cem.canonical_transaction.likely_hack_club_fee?

      #reason = "REVENUE WAIVED" # special case for transaction

      reason = "REVENUE" if cem.canonical_transaction.amount_cents > 0

      reason
    end
  end
end
