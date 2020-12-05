module PendingEventMappingEngine
  class Nightly
    def run
      map_canonical_pending_stripe!

      true
    end

    private

    def map_canonical_pending_stripe!
      ::PendingEventMappingEngine::Map::Stripe.new.run
    end
  end
end
