class PartnerDonation < ApplicationRecord
  belongs_to :partner

  before_create :set_hcb_code

  private

  def set_hcb_code
    self.hcb_code = "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::PARTNER_DONATION_CODE}-#{id}"
  end
end
