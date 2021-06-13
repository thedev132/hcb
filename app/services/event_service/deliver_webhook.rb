module EventService
  class DeliverWebhook
    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      raise ArgumentError, 'webhook_url missing' unless event.webhook_url.present?

      res = Faraday.post(event.webhook_url, Api::V1::OrganizationSerializer.new(event: event).run.to_json, 'Content-Type' => 'application/json')

      if !res.success?
        raise ArgumentError, "Error delivering webhook. HTTP status: #{res.status}"
      end

      res
    end

    private

    def event
      Event.find(@event_id)
    end

  end
end
