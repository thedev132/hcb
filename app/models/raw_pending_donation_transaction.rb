class RawPendingDonationTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "DONATION".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= donation.event.id
  end

  def donation
    @donation ||= ::Donation.find_by(id: donation_transaction_id)
  end
end
