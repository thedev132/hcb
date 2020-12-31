module TransactionEngine
  module Shared
    def last_1_month
      Time.now.utc - 1.month
    end
  end
end
