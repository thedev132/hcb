# frozen_string_literal: true

class RawPendingPartnerDonationTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "DONATION (partner)".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= partner_donation.event.id
  end

  def partner_donation
    @partner_donation ||= ::PartnerDonation.find_by(id: partner_donation_transaction_id)
  end
end
