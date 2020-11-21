module Partners
  module Emburse
    module Transactions
      class Get
        def initialize(emburse_id:)
          @emburse_id = emburse_id
        end

        def run
          EmburseClient::Transaction.get(@emburse_id)
        end
      end
    end
  end
end
