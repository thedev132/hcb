module GSuiteService
  class Create
    def initialize(current_user:, g_suite_application:, event_id:,
                   domain:, verification_key:, dkim_key:)
      @current_user = current_user
      @event_id = event_id
      @g_suite_application = g_suite_application
      @domain = domain
      @verification_key = verification_key
      @dkim_key = dkim_key
    end

    def run
      @g_suite_application.accepted_at = Time.now
      @g_suite_application.fulfilled_by = @current_user

      notify_of_creation if @g_suite_application.save && g_suite.save

      @g_suite
    end

    private

    def recipient
      @g_suite_application.creator.try(:email) || @current_user.email
    end

    def notify_of_creation
      GSuiteMailer.with(recipient: recipient, g_suite_id: g_suite.reload.id).notify_of_creation.deliver_now
    end

    def g_suite_attrs
      {
        event_id: event.id,
        domain: @domain,
        verification_key: @verification_key,
        dkim_key: @dkim_key
      }
    end

    def g_suite
      @g_suite ||= GSuite.new(g_suite_attrs)
    end

    def event
      @event ||= Event.find(@event_id)
    end
  end
end
