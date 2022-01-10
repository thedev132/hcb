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
      # Prefixing the G Suite id with `G` will it easier to search for them in
      # the Google Admin Dashboard.
      "##{@g_suite.event.id} G##{@g_suite.id}"

      # The old OU name used to be in the format of:
      #   "##{event.id} #{event.name.to_s.gsub("+", "")}".strip
      #
      # This was very brittle. Event names that contained special characters
      # would fail with "invalid: Invalid Ou Id".
      # See https://github.com/hackclub/bank/issues/1741
    end

    def org_unit_path
      "#{PARENT_ORG_UNIT_PATH}/#{org_unit_name}"
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
