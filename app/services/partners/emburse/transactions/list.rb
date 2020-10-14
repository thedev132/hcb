module Partners
  module Emburse
    module Transactions
      class List
        def initialize(start_date:, end_date:)
          @start_date = start_date || (Time.now - 5.years).iso8601
          @end_date = end_date || (Time.now + 2.days).iso8601
        end

        def run
          Rails.logger.info "emburse_client.transaction.get start_date=#{@start_date} end_date=#{@end_date}"
          EmburseClient::Transaction.search(search_attrs)
        end

        private

        def search_attrs
          {
            before: @end_date,
            after: @start_date
          }.compact
        end
      end
    end
  end
end
