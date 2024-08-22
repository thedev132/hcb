# frozen_string_literal: true

class Event
  class Plan
    class CardsOnly < Standard
      def label
        "Card-Only Plan (#{revenue_fee_label})"
      end

      def description
        "Only has access to cards for spending and can't raise money, often used for one-off events like Outernet or Winter Hardware Wonderland."
      end

      def features
        %w[cards]
      end

    end

  end

end
