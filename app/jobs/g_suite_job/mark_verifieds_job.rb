# frozen_string_literal: true

module GSuiteJob
  class MarkVerifieds < ApplicationJob
    def perform
      GSuite.verifying.pluck(:id).each do |g_suite_id|
        begin
          GSuiteService::MarkVerified.new(g_suite_id: g_suite_id).run
        rescue => e
          Airbrake.notify(e)
        end
      end
    end
  end
end
