module GSuiteService
  class Update
    def initialize(g_suite_id:, domain:, verification_key:, dkim_key: nil)
      @g_suite_id = g_suite_id

      @domain = domain
      @verification_key = verification_key
      @dkim_key = dkim_key
    end

    def run
      ActiveRecord::Base.transaction do
        domain_changing?

        g_suite.domain = @domain
        g_suite.verification_key = smart_verification_key
        g_suite.dkim_key = @dkim_key
        g_suite.save!

        if domain_changing?
          ::Partners::Google::GSuite::DeleteDomain.new(domain: @domain).run
          ::Partners::Google::GSuite::CreateDomain.new(domain: @domain).run

          notify_operations
        end

        g_suite
      end
    end

    private

    def notify_operations
      OperationsMailer.with(g_suite_id: g_suite.id).g_suite_entering_created_state.deliver_now
    end

    def g_suite
      @g_suite ||= ::GSuite.find(@g_suite_id)
    end

    def domain_changing?
      @domain_changing ||= g_suite.domain != @domain
    end

    def smart_verification_key
      @smart_verification_key ||= domain_changing? ? nil : @verification_key
    end
  end
end
