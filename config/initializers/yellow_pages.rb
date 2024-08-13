# frozen_string_literal: true

YellowPages.missing_merchant_reporter = ->(network_id) do
  ahoy = Ahoy::Tracker.new
  ahoy.track("Merchant Network ID not found", network_id:)
end
