# frozen_string_literal: true

module OneTimeJob
  class PopulateGSuiteCreatedBys < ApplicationJob
    def perform
      OneTimeService::PopulateGSuiteCreatedBys.new.run
    end
  end
end
