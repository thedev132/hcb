# frozen_string_literal: true

module OneTimeService
  class PopulateGSuiteAasmState
    def run
      GSuite.find_each do |g_suite|
        g_suite.update_column(:aasm_state, "verified") if g_suite.verified_on_google?
      end
    end
  end
end
