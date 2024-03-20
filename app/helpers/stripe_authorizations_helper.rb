# frozen_string_literal: true

module StripeAuthorizationsHelper
  def is_city_or_phone?(str)
    return nil if str.blank?

    has_digits = str.scan(/\d/).any?
    has_digits ? :phone : :city
  end

  def humanized_merchant_name(merchant)
    lookup_merchant(merchant["network_id"]) || merchant["name"].titleize
  end

  def lookup_merchant(network_id)
    ahoy = Ahoy::Tracker.new

    result = YellowPages::Merchant.lookup_name(network_id:)

    ahoy.track("Merchant Network ID not found", network_id:) unless result

    result
  end
end
