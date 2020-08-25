# frozen_string_literal: true

module OneTimeJob
  class PopulateGSuiteAasmStateJob < ApplicationJob
    def perform
      OneTimeService::PopulateGSuiteAasmState.new.run
    end
  end
end
