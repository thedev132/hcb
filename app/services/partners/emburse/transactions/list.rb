module Partners
  module Emburse
    module Transactions
      class List
        def initialize(after: nil, before: nil)
          @after = after
          @before = before
        end

        def run
          EmburseClient::Transaction.search(search_attrs)
        end

        private

        def search_attrs
          {
            after: after,
            before: before
          }.compact
        end

        def after
          @after ||= from.iso8601
        end

        def before
          @before ||= (from + 10.days).iso8601
        end

        def from
          10.days.ago
        end
      end
    end
  end
end
