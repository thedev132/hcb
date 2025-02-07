# frozen_string_literal: true

class AirbrakeSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    Airbrake.notify(error, { context:, handled:, severity:, source: })
  end

end

Rails.error.subscribe(AirbrakeSubscriber.new)
