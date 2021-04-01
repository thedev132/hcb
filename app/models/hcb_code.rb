# frozen_string_literal: true

class HcbCode < ApplicationRecord
  include Hashid::Rails

  include Commentable
  include Receiptable

  monetize :amount_cents

  def amount_cents
    @amount_cents ||= begin
      return canonical_transactions.sum(:amount_cents) if canonical_transactions.exists?

      canonical_pending_transactions.sum(:amount_cents)
    end
  end

  def canonical_pending_transactions
    CanonicalPendingTransaction.where(hcb_code: hcb_code)
  end

  def canonical_transactions
    CanonicalTransaction.where(hcb_code: hcb_code)
  end

  def event
    @event ||= canonical_pending_transactions.try(:first).try(:event) || canonical_transactions.try(:first).try(:event)
  end

  # categories
  def donation?
    hcb_category == ::TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE
  end
  
  def invoice?
    hcb_category == ::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE
  end

  # relationships
  def donation
    @donation ||= Donation.find_by(id: hcb_identifier)
  end

  def invoice
    @invoice ||= Invoice.find_by(id: hcb_identifier)
  end

  private

  def hcb_category
    @hcb_catgegory ||= code_parts[1]
  end

  def hcb_identifier
    @hcb_identifier ||= code_parts[2]
  end

  def code_parts
    @code_parts ||= hcb_code.split("-")
  end
end
