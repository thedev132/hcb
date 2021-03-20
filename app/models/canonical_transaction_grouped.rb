# frozen_string_literal: true

class CanonicalTransactionGrouped
  include ActiveModel::Model

  attr_accessor :hcb_code, :date, :amount_cents, :raw_canonical_transaction_ids

  def memo
    return "INVOICE TO #{invoice.memo}" if invoice?

    ct.smart_memo
  end

  def amount
    @amount ||= Money.new(amount_cents, "USD")
  end

  def url
    return "/invoices/#{invoice.id}" if invoice?

    "/transactions/#{ct.id}" # TODO: replace with hcb_code to provide dynamic smart transaction page
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(id: canonical_transaction_ids)
  end

  def fee_payment?
    ct.fee_payment?
  end

  def check
    ct.check
  end

  def ach_transfer
    ct.ach_transfer
  end

  def raw_stripe_transaction
    ct.raw_stripe_transaction
  end

  def donation
    ct.donation
  end

  def disbursement
    ct.disbursement
  end
  
  def invoice?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE
  end

  private

  def invoice
    Invoice.find(hcb_i2)
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
    hcb_code || ::TransactionGroupingEngine::Calculate::HcbCode.new(canonical_transaction: canonical_transactions.first)
  end

  def split_code
    @split_code ||= smart_hcb_code.split(::TransactionGroupingEngine::Calculate::HcbCode::SEPARATOR)
  end

  def canonical_transaction_ids
    JSON.parse(raw_canonical_transaction_ids)
  end

  def ct
    canonical_transactions.first
  end
end
