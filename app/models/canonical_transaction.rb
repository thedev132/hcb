class CanonicalTransaction < ApplicationRecord
  include Receiptable

  scope :unmapped, -> { includes(:canonical_event_mapping).where(canonical_event_mappings: {canonical_transaction_id: nil}) }

  scope :revenue, -> { where("amount_cents > 0") }
  scope :expense, -> { where("amount_cents < 0") }

  scope :likely_github, -> { where("memo ilike '%github grant%'") }
  scope :likely_hack_club_fee, -> { where("memo ilike '%Hack Club Bank Fee TO ACCOUNT%'") }

  monetize :amount_cents

  has_many :canonical_hashed_mappings
  has_many :hashed_transactions, through: :canonical_hashed_mappings
  has_one :canonical_event_mapping
  has_one :event, through: :canonical_event_mapping
  has_one :canonical_pending_settled_mapping
  has_one :canonical_pending_transaction, through: :canonical_pending_settled_mapping
  has_many :fees, through: :canonical_event_mapping

  def smarter_memo
    case linked_object.class.to_s
    when "Disbursement"
      disbursement.name.to_s.upcase
    when "Invoice"
      invoice.sponsor.name.to_s.upcase
    else
      return (raw_emburse_transaction.bank_account_description || raw_emburse_transaction.merchant_description).to_s.upcase if amount_cents > 0 && raw_emburse_transaction.present?

      case deprecated_linked_object.class.to_s
      when "Transaction"
        deprecated_linked_object.display_name.to_s.upcase
      else
        smart_memo
      end
    end
  end

  def smart_memo
    @smart_memo ||= ::TransactionEngine::SyntaxSugarService::Memo.new(canonical_transaction: self).run
  end

  def likely_hack_club_fee?
    memo.to_s.upcase.include?("HACK CLUB BANK FEE TO ACCOUNT")
  end

  def linked_object
    @linked_object ||= TransactionEngine::SyntaxSugarService::LinkedObject.new(canonical_transaction: self).run
  end

  def deprecated_linked_object
    @related_deprecated_linked_object ||= begin
      obj = nil

      if raw_plaid_transaction
        ts = Transaction.where(plaid_id: raw_plaid_transaction.plaid_transaction_id)

        raise ArgumentError unless ts.count == 1

        obj = ts.first
      end

      obj
    end
  end

  # DEPRECATED
  def marked_no_or_lost_receipt_at=(v)
    v
  end

  def marked_no_or_lost_receipt_at
    nil
  end

  def display_name # in deprecated system this is the renamed transaction name
    smarter_memo
  end

  def name # in deprecated system this is the imported name
   smarter_memo
  end

  def filter_data
    {} # TODO
  end

  def comments
    [] # TODO
  end

  def fee_payment?
    false # TODO
  end

  def invoice
    return linked_object if linked_object.is_a?(Invoice)

    nil
  end

  def invoice_payout
    return linked_object.payout if linked_object.is_a?(Invoice)

    nil
  end

  def fee_reimbursement
    nil # TODO
  end

  def check
    return linked_object if linked_object.is_a?(Check)

    nil
  end

  def ach_transfer
    return linked_object if linked_object.is_a?(AchTransfer)

    nil
  end

  def donation_payout
    return linked_object.payout if linked_object.is_a?(Donation)

    nil
  end

  def fee_applies?
    @fee_applies ||= fees.greater_than_0.exists?
  end

  def emburse_transfer
    nil # TODO
  end

  def disbursement
    return linked_object if linked_object.is_a?(Disbursement)

    nil
  end

  private

  def raw_plaid_transaction
    hashed_transaction.raw_plaid_transaction
  end

  def raw_emburse_transaction
    hashed_transaction.raw_emburse_transaction
  end

  def hashed_transaction
    @hashed_transaction ||= begin
      raise ArgumentError if hashed_transactions.count != 1

      hashed_transactions.first
    end
  end
end
