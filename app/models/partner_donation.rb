# frozen_string_literal: true

class PartnerDonation < ApplicationRecord
  include AASM
  include Commentable

  belongs_to :event

  before_create :set_donation_identifier
  after_create :set_hcb_code

  scope :pending, -> { where(aasm_state: "pending") }
  scope :not_pending, -> { where.not(aasm_state: "pending") }
  scope :in_transit, -> { where(aasm_state: "in_transit") }
  scope :not_in_transit, -> { where.not(aasm_state: "in_transit") }
  scope :deposited, -> { where(aasm_state: "deposited") }
  scope :not_deposited, -> { where.not(aasm_state: "deposited") }

  aasm do
    state :pending, initial: true # once created
    state :in_transit # when imported and marked as paid on Stripe::Charge
    state :deposited # when fully deposited to canonical transaction

    event :mark_in_transit do
      before do
        local_hcb_code # lazy create hcb code object
      end

      transitions from: :pending, to: :in_transit
    end

    event :mark_deposited do
      transitions from: :in_transit, to: :deposited
    end
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def stripe_dashboard_url
    "https://dashboard.stripe.com/payments/#{self.stripe_charge_id}"
  end

  def paid?
    self.stripe_charge_id.present?
  end

  def partner
    Partner.find(self.event.partner_id)
  end

  def state
    self.aasm.current_state
  end

  def state_text
    case state
    when :pending
      "Pending"
    when :in_transit
      "In transit"
    when :deposited
      "Deposited"
    else
      "Unknown State"
    end
  end

  def state_color
    case state
    when :pending
      "muted"
    when :in_transit
      "info"
    when :deposited
      "success"
    else
      "error"
    end
  end

  private

  def set_hcb_code
    self.update_column(:hcb_code, "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::PARTNER_DONATION_CODE}-#{id}")
  end

  def set_donation_identifier
    self.donation_identifier = "dnt_#{SecureRandom.hex}"
  end
end
