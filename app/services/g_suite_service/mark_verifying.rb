# frozen_string_literal: true

module GSuiteService
  class MarkVerifying
    def initialize(g_suite_id:)
      @g_suite_id = g_suite_id
    end

    def run
      g_suite.mark_verifying!
    end

    private

    def g_suite
      @g_suite ||= GSuite.find(@g_suite_id)
    end
  end
end
