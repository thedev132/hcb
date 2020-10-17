module Partners
  module Google
    module GSuite
      class OrgUnits
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(org_unit_path:)
          @org_unit_path = org_unit_path
        end

        def run
          directory_client.list_org_units(gsuite_customer_id, org_unit_path: @org_unit_path)
        end
      end
    end
  end
end
