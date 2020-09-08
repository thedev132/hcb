# frozen_string_literal: true

module OneTimeJob
  class PopulateGSuiteAasmState < ApplicationJob
    def perform
      OneTimeService::PopulateGSuiteAasmState.new.run
    end
  end
end
