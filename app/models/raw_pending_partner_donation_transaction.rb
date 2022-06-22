# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_pending_partner_donation_transactions
#
#  id                              :bigint           not null, primary key
#  amount_cents                    :integer
#  date_posted                     :date
#  state                           :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  partner_donation_transaction_id :text
#
class RawPendingPartnerDonationTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "DONATION".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= partner_donation.event.id
  end

  def partner_donation
    @partner_donation ||= ::PartnerDonation.find_by(id: partner_donation_transaction_id)
  end

end
