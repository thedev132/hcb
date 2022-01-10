# frozen_string_literal: true

module PartnerDonationsHelper

  def partner_donation_paid_at(partner_donation = @partner_donation)
    timestamp = partner_donation&.stripe_charge_created_at
    timestamp ? format_datetime(timestamp) : "–"
  end

  def partner_donation_initiated_at(partner_donation = @partner_donation)
    timestamp = partner_donation&.created_at
    timestamp ? format_datetime(timestamp) : "–"
  end

  def partner_donation_payment_method_mention(partner_donation = @partner_donation, options = {})
    return "–" unless partner_donation&.payment_method_type

    if partner_donation&.payment_method_card_brand
      brand = partner_donation&.payment_method_card_brand
      last4 = partner_donation&.payment_method_card_last4

      icon_name = {
        "amex"       => "card-amex",
        "mastercard" => "card-mastercard",
        "visa"       => "card-visa",
        "discover"   => "card-discover"
      }[brand] || "card-other"
      tooltip = {
        "amex"       => "American Express",
        "mastercard" => "Mastercard",
        "visa"       => "Visa",
        "discover"   => "Discover"
      }[brand] || "Card"
      tooltip += " ending in #{last4}" if last4 && organizer_signed_in?
      description_text = organizer_signed_in? ? "••••#{last4}" : "••••"
      icon = inline_icon icon_name, width: 32, height: 20, class: "slate"
    else
      icon_name = "bank-account"
      size = 20

      if partner_donation&.payment_method_type == "ach_credit_transfer"
        description_text = "ACH Transfer"
      else
        description_text = partner_donation.payment_method_type.humanize
      end
    end

    description = content_tag :span, description_text, class: "ml1"
    icon ||= inline_icon icon_name, width: size, height: size, class: "slate"
    content_tag(:span, class: "inline-flex items-center #{options[:class]}") { icon + description }
  end

  def partner_donation_card_country_mention(partner_donation = @partner_donation)
    country_code = partner_donation&.payment_method_card_country

    return nil unless country_code

    # Hack to turn country code into the country's flag
    # https://stackoverflow.com/a/50859942
    emoji = country_code.tr("A-Z", "\u{1F1E6}-\u{1F1FF}")

    content_tag :span, emoji, class: "tooltipped tooltipped--w pr1", 'aria-label': country_code
  end

  def partner_donation_card_check_badge(check, partner_donation = @partner_donation)
    case partner_donation.send("payment_method_card_checks_#{check}_check")
    when "pass"
      background = "success"
      icon_name = "checkmark"
      text = "Passed"
    when "failed"
      background = "warning"
      icon_name = "view-close"
      text = "Failed"
    when "unchecked"
      background = "info"
      icon_name = "checkbox"
      text = "Unchecked"
    else
      background = "smoke"
      icon_name = "checkbox"
      text = "Unavailable"
    end

    tag = inline_icon icon_name, size: 24
    content_tag(:span, class: "pr1 #{background} line-height-0 tooltipped tooltipped--w", 'aria-label': text) { tag }
  end

  def partner_donation_fee_type(partner_donation = @partner_donation)
    if partner_donation.payment_method_type == "card"
      brand = partner_donation.payment_method_card_brand.humanize.capitalize
      funding = partner_donation.payment_method_card_funding.humanize.capitalize
      return "#{brand} #{funding} card fee"
    elsif partner_donation.payment_method_type == "ach_credit_transfer"
      "ACH Transfer fee"
    else
      "Transfer fee"
    end
  end

  def partner_donation_payment_processor_fee(humanized = true, partner_donation = @partner_donation)
    fee = partner_donation.amount - partner_donation.payout_amount_cents

    return fee unless humanized

    render_money fee
  end
end
