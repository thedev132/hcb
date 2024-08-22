# frozen_string_literal: true

class Event
  class Plan
    class Standard < Plan
      def revenue_fee
        0.07
      end

      def label
        "Full Fiscal Sponsorship (#{revenue_fee_label})"
      end

      def description
        "Has access to all standard features, used for most organizations."
      end

      def features
        Event::Plan.available_features
      end

    end

  end

end
