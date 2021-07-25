# frozen_string_literal: true

module Partners
  module Google
    module GSuite
      class DeleteDomain
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(domain:)
          @domain = domain
        end

        def run
          directory_client.delete_domain(gsuite_customer_id, @domain)
        end
      end
    end
  end
end
