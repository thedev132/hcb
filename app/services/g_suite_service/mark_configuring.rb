# frozen_string_literal: true

module GSuiteService
  class MarkConfiguring
    def initialize(g_suite_id:)
      @g_suite_id = g_suite_id
    end

    def run
      ActiveRecord::Base.transaction do
        raise ArgumentError, "verification_key is required" unless g_suite.verification_key.present?

        g_suite.mark_configuring!

        g_suite
      end
    end

    private

    def g_suite
      @g_suite ||= GSuite.find(@g_suite_id)
    end
  end
end
