# frozen_string_literal: true

module FeeEngine
  class Hourly
    def run
      CanonicalEventMapping.missing_fee.find_each(batch_size: 100) do |cem|
        # Require HCB Code to be present. Allows us to determine if other transactions in
        # this HCB Code had their fees waived.
        return if cem.canonical_transaction.hcb_code.nil?

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

      reason = "REVENUE" if cem.canonical_transaction.amount_cents > 0

      reason = "REVENUE WAIVED" if cem.canonical_transaction.likely_check_clearing_dda? # this typically has a negative balancing transaction with it
      reason = "REVENUE WAIVED" if cem.canonical_transaction.likely_card_transaction_refund? # sometimes a user is issued a refund on a transaction
      reason = "REVENUE WAIVED" if cem.canonical_transaction.likely_disbursement? # don't run fees on disbursements

      # don't run fee if other transactions in it's HCB Code have fees waived
      reason = "REVENUE WAIVED" if cem.canonical_transaction.local_hcb_code.canonical_transactions.map { |ct| ct.fees }.flatten.any? { |fee| fee.reason == "REVENUE WAIVED" }

      reason
    end
  end
end
