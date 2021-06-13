require 'net/http'

module EventService
  class DeliverWebhook
    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      # Don't attempt webhook delivery if no webhook url exists
      return unless event.webhook_url.present?

      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = Api::V1::OrganizationSerializer.new(event: event).run.to_json

      res = http.request(req) # this doesn't support http redirects (since redirects are 3XX, it'll error)
      # non 2XX will throw a Net error. don't rescue to let sidekiq reattempt webhook delivery after failure

      res
    end

    private

    def event
      Event.find(@event_id)
    end

    def http
      Net::HTTP.new(uri.host, uri.port)
    end

    def uri
      URI.parse(event.webhook_url)
    end

  end
end
