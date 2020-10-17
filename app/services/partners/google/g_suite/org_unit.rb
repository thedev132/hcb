module Partners
  module Google
    module GSuite
      class OrgUnit
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(org_unit_path:)
          @org_unit_path = org_unit_path
        end

        def run
          directory_client.get_org_unit(gsuite_customer_id, org_unit_path_without_leading_slash)
        rescue ::Google::Apis::ClientError => e
          # re-raise unless 404
          raise e unless e.status_code == 404
        end

        private

        def org_unit_path_without_leading_slash
          @org_unit_path.split('/').reject { |c| c.empty? }.join('/')
        end
      end
    end
  end
end
