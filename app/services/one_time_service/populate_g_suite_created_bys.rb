# frozen_string_literal: true

module OneTimeService
  class PopulateGSuiteCreatedBys
    def run
      GSuite.where("created_by_id is null").find_each do |g_suite|
        user = g_suite.event.users.order("created_at asc").first

        g_suite.update_column(:created_by_id, user.id) if user
      end
    end
  end
end
