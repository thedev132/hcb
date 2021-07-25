# frozen_string_literal: true

module Partners
  module Google
    module GSuite
      class UpdateOrgUnit
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(org_unit_path:, org_unit_object:)
          @org_unit_path = org_unit_path
          @org_unit_object = org_unit_object
        end

        def run
          directory_client.update_org_unit(gsuite_customer_id, org_unit_path: @org_unit_path)
        end
      end
    end
  end
end
