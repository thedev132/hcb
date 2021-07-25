# frozen_string_literal: true

module Shared
  module AmpleBalance
    def ample_balance?
      if ENV["EXCLUDE_PENDING_FEES_FROM_AMPLE_BALANCE"] == "true"
        event.balance_v2_cents >= @amount_cents
      else
        # includes pending fees
        event.balance_available_v2_cents >= @amount_cents
      end
    end
  end
end
