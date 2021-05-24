class PartnerDonation < ApplicationRecord
  belongs_to :event

  before_create :set_hcb_code
  before_create :set_donation_identifier

  private

  def set_hcb_code
    self.hcb_code = "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::PARTNER_DONATION_CODE}-#{id}"
  end

  def set_donation_identifier
    self.donation_identifier = "dnt_#{SecureRandom.hex}"
  end
end
