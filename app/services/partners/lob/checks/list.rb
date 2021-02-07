module Partners
  module Lob
    module Checks
      class List
        include StripeService

        def initialize(start_date: nil)
          @start_date = start_date || Time.now.utc - 1.month
        end

        def run
          lob_checks
        end

        private

        def api_version
          "2018-06-05"
        end

        def api_key
          return Rails.application.credentials.lob[:production][:api_key] if Rails.env.production?

          Rails.application.credentials.lob[:development][:api_key]
        end

        def client
          @client ||= ::Lob::Client.new(api_key: api_key, api_version: api_version)
        end

        def lob_checks
          resp = fetch_checks

          ts = resp["data"]

          while resp["next_url"]

            parsed = Rack::Utils.parse_nested_query resp.next_url

            after = parsed["after"]

            resp = fetch_checks(after: after)

            ts += resp["data"]
          end

          ts
        end

        def fetch_checks(after: nil)
          client.checks.list(list_attrs(after: after))
        end

        def list_attrs(after:)
          {
            after: after,
            date_created: { gte: date_created_gte },
            limit: 100,
            "include[]" => "total_count"
          }.compact
        end

        def date_created_gte
          @start_date.to_date.to_s
        end
      end
    end
  end
end
