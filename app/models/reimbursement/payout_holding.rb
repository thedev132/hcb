# frozen_string_literal: true

# == Schema Information
#
# Table name: reimbursement_payout_holdings
#
#  id                       :bigint           not null, primary key
#  aasm_state               :string
#  amount_cents             :integer          not null
#  hcb_code                 :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  ach_transfers_id         :bigint
#  increase_checks_id       :bigint
#  reimbursement_reports_id :bigint           not null
#
# Indexes
#
#  index_reimbursement_payout_holdings_on_ach_transfers_id          (ach_transfers_id)
#  index_reimbursement_payout_holdings_on_increase_checks_id        (increase_checks_id)
#  index_reimbursement_payout_holdings_on_reimbursement_reports_id  (reimbursement_reports_id)
#
module Reimbursement
  class PayoutHolding < ApplicationRecord
    include AASM
    include HasBookTransfer

    has_many :expense_payouts, class_name: "Reimbursement::ExpensePayout", foreign_key: "reimbursement_payout_holdings_id", inverse_of: :payout_holding
    belongs_to :report, foreign_key: "reimbursement_reports_id", inverse_of: :payout_holding
    belongs_to :ach_transfer, optional: true
    belongs_to :increase_check, optional: true

    after_create :set_and_create_hcb_code
    belongs_to :local_hcb_code, foreign_key: "hcb_code", primary_key: "hcb_code", class_name: "HcbCode", inverse_of: :reimbursement_payout_holding, optional: true
    has_many :canonical_transactions, through: :local_hcb_code

    aasm do
      state :pending, initial: true
      state :in_transit
      state :settled
      state :sent

      event :mark_in_transit do
        transitions from: :pending, to: :in_transit
      end

      event :mark_settled do
        transitions from: :in_transit, to: :settled
      end

      event :mark_sent do
        transitions from: :settled, to: :sent
      end
    end

    private

    def set_and_create_hcb_code
      self.update_column(:hcb_code, "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::PAYOUT_HOLDING_CODE}-#{id}")
      HcbCode.find_or_create_by(hcb_code:)
    end

  end
end
