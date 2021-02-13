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
      decline_canonical_pending_donation!

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

    def decline_canonical_pending_donation!
      #::PendingEventMappingEngine::Decline::Donation.new.run
    end

  end
end
