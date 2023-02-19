# frozen_string_literal: true

# == Schema Information
#
# Table name: ach_payments
#
#  id                           :bigint           not null, primary key
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  fee_reimbursement_id         :bigint
#  stripe_ach_payment_source_id :bigint           not null
#  stripe_charge_id             :text
#  stripe_payout_id             :text
#  stripe_source_transaction_id :text
#
# Indexes
#
#  index_ach_payments_on_fee_reimbursement_id          (fee_reimbursement_id)
#  index_ach_payments_on_stripe_ach_payment_source_id  (stripe_ach_payment_source_id)
#
# Foreign Keys
#
#  fk_rails_...  (stripe_ach_payment_source_id => stripe_ach_payment_sources.id)
#
class AchPayment < ApplicationRecord
  belongs_to :stripe_ach_payment_source
  has_one :event, through: :stripe_ach_payment_source
  belongs_to :fee_reimbursement, required: false

  def stripe_fee
    stripe_charge.balance_transaction.fee
  end

  def net_amount
    stripe_charge.balance_transaction.net
  end

  def hcb_code
    "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::ACH_PAYMENT_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def create_stripe_payout!
    payout = StripeService::Payout.create(
      amount: net_amount,
      currency: "usd",
      statement_descriptor: "HCB-#{local_hcb_code.short_code}"
    )

    update!(stripe_payout_id: payout.id)
  end

  private

  def stripe_charge
    @stripe_charge ||= StripeService::Charge.retrieve(id: stripe_charge_id, expand: ["balance_transaction"])
  end

end
