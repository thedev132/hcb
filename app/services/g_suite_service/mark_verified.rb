# frozen_string_literal: true

module GSuiteService
  class MarkVerified
    def initialize(g_suite_id:)
      @g_suite_id = g_suite_id
    end

    def run
      ActiveRecord::Base.transaction do
        g_suite.mark_verified! if verified_on_google?

        notify_of_verified

        g_suite
      end
    end

    private

    def verified_on_google?
      ::Partners::Google::GSuite::Domain.new(domain: g_suite.domain).run.verified
    end

    def g_suite
      @g_suite ||= GSuite.find(@g_suite_id)
    end

    def notify_of_verified
      GSuiteMailer.with(recipient: g_suite.created_by.email, g_suite_id: g_suite.id).notify_of_verified.deliver_now if g_suite.created_by.present?
    end
  end
end
