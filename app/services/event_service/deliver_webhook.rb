# frozen_string_literal: true

module EventService
  class DeliverWebhook
    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      raise ArgumentError, "webhook_url missing" unless event.webhook_url.present?

      res = conn.post(event.webhook_url) do |req|
        req.body = Api::V1::OrganizationSerializer.new(event: event).run.to_json
      end

      raise ArgumentError, "Error delivering webhook. HTTP status: #{res.status}" unless res.success?

      res
    end

    private

    def conn
      @conn ||= begin
        Faraday.new(new_attrs) do |faraday|
          faraday.use FaradayMiddleware::FollowRedirects, limit: 10
        end
      end
    end

    def new_attrs
      {
        headers: {"Content-Type" => "application/json"}
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end

  end
end
