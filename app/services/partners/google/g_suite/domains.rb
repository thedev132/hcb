# frozen_string_literal: true

module Partners
  module Google
    module GSuite
      class Domains
        include Partners::Google::GSuite::Shared::DirectoryClient

        def run
          directory_client.list_domains(gsuite_customer_id)
        end
      end
    end
  end
end
