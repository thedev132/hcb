module PendingEventMappingEngine
  class Nightly
    def run
      map_canonical_pending_outgoing_check!
      settle_canonical_pending_outgoing_check!
      decline_canonical_pending_outgoing_check!

      #map_canonical_pending_stripe!

      #settle_canonical_pending_stripe!

      #decline_canonical_pending_stripe!

      true
    end

    private

    def map_canonical_pending_outgoing_check!
      ::PendingEventMappingEngine::Map::OutgoingCheck.new.run
    end

    def settle_canonical_pending_outgoing_check!
      #::PendingEventMappingEngine::Map::OutgoingCheck.new.run
    end

    def decline_canonical_pending_outgoing_check!
      #::PendingEventMappingEngine::Map::OutgoingCheck.new.run
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

  end
end
