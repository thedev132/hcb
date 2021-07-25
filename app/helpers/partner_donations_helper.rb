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
end
