# frozen_string_literal: true

class HcbCode < ApplicationRecord
  include Hashid::Rails

  include Commentable
  include Receiptable

  monetize :amount_cents

  def url
    "/hcb/#{hashid}"
  end

  def date
    @date ||= ct.try(:date) || pt.try(:date)
  end

  def memo
    return invoice_memo if invoice?
    return donation_memo if donation?
    return ach_transfer_memo if ach_transfer?
    return check_memo if check?
    return ct.try(:smart_memo) || pt.try(:smart_memo) if stripe_card?

    ct.try(:smart_memo) || pt.try(:smart_memo) || ""
  end

  def amount_cents
    @amount_cents ||= begin
      return canonical_transactions.sum(:amount_cents) if canonical_transactions.exists?

      canonical_pending_transactions.sum(:amount_cents)
    end
  end

  def canonical_pending_transactions
    @canonical_pending_transactions ||= CanonicalPendingTransaction.where(hcb_code: hcb_code)
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(hcb_code: hcb_code).order("date desc, id desc")
  end

  def event
    events.first
  end

  def events
    @events ||= begin
      ids = [
        canonical_pending_transactions.map { |cpt| cpt.event.id },
        canonical_transactions.map { |ct| ct.event.id },
        invoice.try(:event).try(:id),
        donation.try(:event).try(:id),
        ach_transfer.try(:event).try(:id),
        check.try(:event).try(:id),
        disbursement.try(:event).try(:id)
      ].compact.flatten.uniq

      Event.where(id: ids)
    end
  end

  def fee_payment?
    ct.fee_payment?
  end

  def raw_stripe_transaction
    ct.raw_stripe_transaction
  end

  def stripe_card
    pt.try(:stripe_card) || ct.try(:stripe_card)
  end

  def stripe_cardholder
    pt.try(:stripe_cardholder) || ct.try(:stripe_cardholder)
  end

  def invoice?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE
  end

  def donation?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE
  end

  def ach_transfer?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::ACH_TRANSFER_CODE
  end

  def check?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::CHECK_CODE
  end

  def disbursement?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::DISBURSEMENT_CODE
  end

  def stripe_card?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::STRIPE_CARD_CODE
  end

  def invoice
    @invoice ||= Invoice.find_by(id: hcb_i2)
  end

  def invoice_memo
    smartish_custom_memo || "INVOICE TO #{invoice.smart_memo}"
  end

  def donation
    @donation ||= Donation.find_by(id: hcb_i2)
  end

  def donation_memo
    smartish_custom_memo || "DONATION FROM #{donation.smart_memo}"
  end

  def ach_transfer
    @ach_transfer ||= AchTransfer.find_by(id: hcb_i2)
  end

  def ach_transfer_memo
    smartish_custom_memo || "ACH TO #{ach_transfer.smart_memo}"
  end

  def check
    @check ||= Check.find_by(id: hcb_i2)
  end

  def check_memo
    smartish_custom_memo || "CHECK TO #{check.smart_memo}"
  end

  def disbursement
    @disbursement ||= Disbursement.find_by(id: hcb_i2)
  end

  def unknown?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::UNKNOWN_CODE
  end

  def hcb_i1
    split_code[1]
  end

  def hcb_i2
    split_code[2]
  end

  def smart_hcb_code
    hcb_code || ::TransactionGroupingEngine::Calculate::HcbCode.new(canonical_transaction_or_canonical_pending_transaction: canonical_transactions.first)
  end

  def split_code
    @split_code ||= smart_hcb_code.split(::TransactionGroupingEngine::Calculate::HcbCode::SEPARATOR)
  end

  def canonical_transaction_ids
    JSON.parse(raw_canonical_transaction_ids)
  end

  def pt
    canonical_pending_transactions.first
  end

  def ct
    canonical_transactions.first
  end

  def ct2
    canonical_transactions.last
  end

  def smartish_custom_memo
    return nil unless ct.custom_memo
    return ct.custom_memo unless ct.custom_memo.include?("FEE REFUND")

    ct2.custom_memo
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

end
