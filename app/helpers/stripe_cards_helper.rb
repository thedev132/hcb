# frozen_string_literal: true

module StripeCardsHelper
  def render_exp_date(card = @card)
    "#{card.stripe_exp_month.to_s.rjust(2, '0')}/#{card.stripe_exp_year}"
  end

  def stripe_card_mention(stripe_card, options = { size: 24 })
    icon = inline_icon "card",
      size: options[:size],
      class: "purple #{options[:size] <= 24 ? 'pr1' : ''}"
    if organizer_signed_in? || stripe_card.user == current_user
      text = content_tag :span, stripe_card.last_four
      return link_to(stripe_card, class: "mention") { icon + text }
    else
      text = content_tag :span, "XXXX"
      return link_to(root_path, class: "mention") { icon + text }
    end
  end

  def suggested(field)
    return nil unless current_user

    ecr = EmburseCardRequest.where(creator_id: current_user&.id)
    case field
    when :phone_number
      current_user.phone_number
    when :name
      current_user.full_name
    when :line1
      current_user&.stripe_cardholder&.stripe_billing_address_line1 ||
      ecr&.last&.shipping_address_street_one
    when :line2
      current_user&.stripe_cardholder&.stripe_billing_address_line2 ||
      ecr&.last&.shipping_address_street_two
    when :city
      current_user&.stripe_cardholder&.stripe_billing_address_city ||
      ecr&.last&.shipping_address_city
    when :state
      current_user&.stripe_cardholder&.stripe_billing_address_state ||
      ecr&.last&.shipping_address_state
    when :postal_code
      current_user&.stripe_cardholder&.stripe_billing_address_postal_code ||
      ecr&.last&.shipping_address_zip
    when :country
      current_user&.stripe_cardholder&.stripe_billing_address_country ||
      ("US" if ecr.any?)
    else
      nil
    end
  end

  def card_shipping_map_url(card, options = {})
    address = "#{card.address_line1} #{card.address_line2}, #{card.address_city} #{card.address_state} #{card.address_country} #{card.address_postal_code}"
    geo = Geocoder.search(address)&.first
    return nil unless geo
    lat = geo.data["lat"]
    return nil unless lat
    lng = geo.data["lon"]
    "https://dev.virtualearth.net/REST/v1/Imagery/Map/Aerial/#{lat},#{lng}/10/?mapSize=512,256&format=jpeg&key=AssBchuxLMpaS6MmACdfDyLpD4X7_T2SZ34cC_KBcWlPU6iZCsWgv0tTbw5Coehm"
  end
end
