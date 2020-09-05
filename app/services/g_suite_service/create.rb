module GSuiteService
  class Create
    def initialize(current_user:, event_id:, domain:)
      @current_user = current_user
      @event_id = event_id
      @domain = domain
    end

    def run
      raise ArgumentError, error_message if event.g_suite.present?

      ActiveRecord::Base.transaction do
        g_suite.save!
        g_suite.reload

        ::Partners::Google::GSuite::CreateDomain.new(domain: @domain).run

        begin
          notify_of_creation
        rescue => e
          ::Partners::Google::GSuite::DeleteDomain.new(domain: @domain).run # roll back g suite domain if email fails for any reason

          raise e
        end

        g_suite
      end
    end

    private

    def notify_of_creation
      GSuiteMailer.with(recipient: @current_user.email, g_suite_id: g_suite.id).notify_of_creation.deliver_now if @current_user.email.present?
    end

    def attrs
      {
        event_id: event.id,
        domain: @domain
      }
    end

    def g_suite
      @g_suite ||= GSuite.new(attrs)
    end

    def event
      @event ||= Event.find(@event_id)
    end

    def error_message
      "You already have a GSuite account for this event"
    end
  end
end
