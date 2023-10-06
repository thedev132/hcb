# frozen_string_literal: true

module PayoutService
  class Nightly
    def run
      ::Donation.where(aasm_state: [:in_transit, :refunded]).missing_payout.each do |donation|
        ::PayoutJob::Donation.perform_later(donation.id)
      end

      ::Invoice.paid_v2.missing_payout.each do |invoice|
        ::PayoutJob::Invoice.perform_later(invoice.id)
      end
    end

  end
end
