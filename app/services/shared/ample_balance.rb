module Shared
  module AmpleBalance
    def ample_balance?
      event.balance_available_v2_cents >= @amount_cents
    end
  end
end
