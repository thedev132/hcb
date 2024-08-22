# frozen_string_literal: true

class Event
  class Plan
    class FeeWaived < Standard
      def revenue_fee
        0.00
      end

    end

  end

end
