module Shared
  module Fee
    module CanonicalFeeMemo
      private

      def canonical_fee_memo(event:)
        "#{event.id} Hack Club Bank Fee"
      end
    end
  end
end
