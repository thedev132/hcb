# frozen_string_literal: true

module GSuiteService
  class FindOrCreateRemoteOrgUnit
    PARENT_ORG_UNIT_PATH = "/Events"

    def initialize(g_suite:)
      @g_suite = g_suite
    end

    def run
      ::Partners::Google::GSuite::OrgUnit.new(show_attrs).run || ::Partners::Google::GSuite::CreateOrgUnit.new(create_attrs).run
    end

    private

    def org_unit_name
      @g_suite.ou_name.strip # TODO: deprecate in model and move directly here
    end

    def org_unit_path
      "#{PARENT_ORG_UNIT_PATH}/#{org_unit_name}" # TODO: make path different than name - use a random hex id or something or the g suite id itself
    end

    def create_attrs
      {
        parent_org_unit_path: PARENT_ORG_UNIT_PATH,
        name: org_unit_name
      }
    end

    def org_unit_id_or_path
      @g_suite.remote_org_unit_id || org_unit_path
    end

    def show_attrs
      {
        org_unit_path: org_unit_id_or_path
      }
    end
  end
end
