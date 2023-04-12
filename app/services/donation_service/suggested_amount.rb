# frozen_string_literal: true

module DonationService
  class SuggestedAmount
    def initialize(event, monthly: false)
      @event = event
      @monthly = monthly

      @donations = if @monthly
                     @event.recurring_donations.where(stripe_status: "active")
                   else
                     @event.donations.succeeded
                   end
    end

    def run
      amounts = @donations.order(amount: :asc).pluck(:amount)
      m = median(amounts) # Median donation amount

      (m * 1.5) # 50% increase to encourage higher donations
        .round(-3) # Round to nearest $10
        .clamp(20_00, 100_00) # Clamp between $20 and $100
    end

    private

    def median(sorted_array)
      return 0 if sorted_array.empty?

      mid = (sorted_array.length - 1) / 2.0
      (sorted_array[mid.floor] + sorted_array[mid.ceil]) / 2.0
    end

  end

end
