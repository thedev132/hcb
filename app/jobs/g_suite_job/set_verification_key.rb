# frozen_string_literal: true

module GSuiteJob
  class SetVerificationKey < ApplicationJob
    def perform(g_suite_id)
      @g_suite_id = g_suite_id
      key = GSuiteService::GetVerificationKey.new(g_suite_id: g_suite_id).run

      GSuiteService::Update.new(g_suite_id: g_suite.id, domain: g_suite.domain, verification_key: key).run
    end

    def g_suite
      GSuite.find(@g_suite_id)
    end
  end
end
