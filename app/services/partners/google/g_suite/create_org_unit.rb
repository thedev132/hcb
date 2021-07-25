# frozen_string_literal: true

module Partners
  module Google
    module GSuite
      class CreateOrgUnit
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(parent_org_unit_path:, name:)
          @parent_org_unit_path = parent_org_unit_path
          @name = name
        end

        def run
          directory_client.insert_org_unit(gsuite_customer_id, org_unit_object)
        end

        private

        def org_unit_object
          ::Google::Apis::AdminDirectoryV1::OrgUnit.new({
            parent_org_unit_path: @parent_org_unit_path,
            name: @name
          })
        end
      end
    end
  end
end
