module PendingEventMappingEngine
  class Nightly
    def run
      map_canonical_pending_outgoing_check!
      settle_canonical_pending_outgoing_check!
      decline_canonical_pending_outgoing_check!

      map_canonical_pending_outgoing_ach!
      settle_canonical_pending_outgoing_ach!
      decline_canonical_pending_outgoing_ach!

      map_canonical_pending_stripe!
      settle_canonical_pending_stripe!
      decline_canonical_pending_stripe!

      map_canonical_pending_donation!
      settle_canonical_pending_donation!
      settle_canonical_pending_donation_hcb_code!
      decline_canonical_pending_donation!

      map_canonical_pending_invoice!
      settle_canonical_pending_invoice!
      settle_canonical_pending_invoice_hcb_code!
      decline_canonical_pending_invoice!

      map_canonical_pending_bank_fee!

      true
    end

    private

    def map_canonical_pending_outgoing_check!
      ::PendingEventMappingEngine::Map::OutgoingCheck.new.run
    end

    def settle_canonical_pending_outgoing_check!
      ::PendingEventMappingEngine::Settle::OutgoingCheck.new.run
    end

    def decline_canonical_pending_outgoing_check!
      ::PendingEventMappingEngine::Decline::OutgoingCheck.new.run
    end

    def map_canonical_pending_outgoing_ach!
      ::PendingEventMappingEngine::Map::OutgoingAch.new.run
    end

    def settle_canonical_pending_outgoing_ach!
      ::PendingEventMappingEngine::Settle::OutgoingAch.new.run
    end

    def decline_canonical_pending_outgoing_ach!
      ::PendingEventMappingEngine::Decline::OutgoingAch.new.run
    end

    def map_canonical_pending_stripe!
      ::PendingEventMappingEngine::Map::Stripe.new.run
    end

    def settle_canonical_pending_stripe!
      ::PendingEventMappingEngine::Settle::Stripe.new.run
    end

    def decline_canonical_pending_stripe!
      ::PendingEventMappingEngine::Decline::Stripe.new.run
    end

    def map_canonical_pending_donation!
      ::PendingEventMappingEngine::Map::Donation.new.run
    end

    def settle_canonical_pending_donation!
      ::PendingEventMappingEngine::Settle::Donation.new.run
    end

    def settle_canonical_pending_donation_hcb_code!
      ::PendingEventMappingEngine::Settle::DonationHcbCode.new.run
    end

    def decline_canonical_pending_donation!
      #::PendingEventMappingEngine::Decline::Donation.new.run
    end

    def map_canonical_pending_invoice!
      ::PendingEventMappingEngine::Map::Invoice.new.run
    end

    def settle_canonical_pending_invoice!
      ::PendingEventMappingEngine::Settle::Invoice.new.run
    end

    def settle_canonical_pending_invoice_hcb_code!
      ::PendingEventMappingEngine::Settle::InvoiceHcbCode.new.run
    end

    def decline_canonical_pending_invoice!
      #::PendingEventMappingEngine::Decline::Invoice.new.run
    end

    def map_canonical_pending_bank_fee!
      ::PendingEventMappingEngine::Map::BankFee.new.run
    end

  end
end
