class PartnerDonation < ApplicationRecord
  include AASM

  belongs_to :event

  before_create :set_donation_identifier
  after_create :set_hcb_code

  aasm do
    state :pending, initial: true # once created
    state :in_transit # when imported and marked as paid on Stripe::Charge
    state :deposited # when fully deposited to canonical transaction

    event :mark_in_transit do
      transitions from: :pending, to: :in_transit
    end

    event :mark_deposited do
      transitions from: :deposited, to: :deposited
    end
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def stripe_dashboard_url
    "https://dashboard.stripe.com/payments/#{self.stripe_charge_id}"
  end

  def paid_at
    timestamp = self.stripe_charge_created_at
    timestamp ? format_datetime(timestamp) : '–'
  end

  def paid?
    self.amount_received != 0
  end

  private

  def set_hcb_code
    self.update_column(:hcb_code, "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::PARTNER_DONATION_CODE}-#{id}")
  end

  def set_donation_identifier
    self.donation_identifier = "dnt_#{SecureRandom.hex}"
  end
end
