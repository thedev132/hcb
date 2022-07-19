# frozen_string_literal: true

# == Schema Information
#
# Table name: hcb_codes
#
#  id                           :bigint           not null, primary key
#  hcb_code                     :text             not null
#  marked_no_or_lost_receipt_at :datetime
#  short_code                   :text
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_hcb_codes_on_hcb_code  (hcb_code) UNIQUE
#
class HcbCode < ApplicationRecord
  has_paper_trail

  include PublicIdentifiable
  set_public_id_prefix :txn

  include Hashid::Rails

  include Commentable
  include Receiptable

  monetize :amount_cents

  before_create :generate_and_set_short_code

  attr_writer :canonical_transactions, :canonical_pending_transactions, :not_admin_only_comments_count

  comma do
    hcb_code "HCB Code"
    created_at "Created at"
    date "Transaction date"
    url "URL" do |url| "https://bank.hackclub.com#{url}" end
    memo
    receipts size: "Receipt count"
    receipts "Has receipt?" do |receipts| receipts.exists? end
  end

  def url
    "/hcb/#{hashid}"
  end

  def receipt_upload_email
    if Rails.env.development?
      "receipts+hcb-#{hashid}@bank-parse-dev.hackclub.com"
    else
      "receipts+hcb-#{hashid}@bank-parse.hackclub.com"
    end
  end

  def date
    @date ||= ct.try(:date) || pt.try(:date)
  end

  def memo
    return disbursement_memo if disbursement?
    return invoice_memo if invoice?
    return donation_memo if donation?
    return partner_donation_memo if partner_donation?
    return ach_transfer_memo if ach_transfer?
    return check_memo if check?

    custom_memo || ct.try(:smart_memo) || pt.try(:smart_memo) || ""
  end

  def type
    return :unknown if unknown?
    return :invoice if invoice?
    return :donation if donation?
    return :partner_donation if partner_donation?
    return :ach if ach_transfer?
    return :check if check?
    return :disbursement if disbursement?
    return :card_charge if stripe_card?

    nil
  end

  def humanized_type
    t = type || :transaction
    t = :transaction if unknown?

    t.to_s.humanize
  end

  def custom_memo
    ct.try(:custom_memo) || pt.try(:custom_memo)
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
        canonical_pending_transactions.map { |cpt| cpt.event&.id },
        canonical_transactions.map { |ct| ct.event&.id },
        invoice.try(:event).try(:id),
        donation.try(:event).try(:id),
        partner_donation.try(:event).try(:id),
        ach_transfer.try(:event).try(:id),
        check.try(:event).try(:id),
        disbursement.try(:event).try(:id)
      ].compact.flatten.uniq

      Event.where(id: ids[0])
    end
  end

  def fee_payment?
    ct.fee_payment?
  end

  def raw_stripe_transaction
    ct&.raw_stripe_transaction
  end

  def stripe_card
    pt.try(:stripe_card) || ct.try(:stripe_card)
  end

  def stripe_cardholder
    pt.try(:stripe_cardholder) || ct.try(:stripe_cardholder)
  end

  def stripe_auth_dashboard_url
    pt.try(:stripe_auth_dashboard_url) || ct.try(:stripe_auth_dashboard_url)
  end

  def invoice?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE
  end

  def donation?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE
  end

  def partner_donation?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::PARTNER_DONATION_CODE
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

  def disbursement_memo
    smartish_custom_memo || "Transfer from #{disbursement.source_event.name} to #{disbursement.destination_event.name}".strip.upcase
  end

  def stripe_card?
    hcb_i1 == ::TransactionGroupingEngine::Calculate::HcbCode::STRIPE_CARD_CODE
  end

  def invoice
    @invoice ||= Invoice.find_by(id: hcb_i2) if invoice?
  end

  def invoice_memo
    smartish_custom_memo || "INVOICE TO #{invoice.smart_memo}"
  end

  def donation
    @donation ||= Donation.find_by(id: hcb_i2) if donation?
  end

  def donation_memo
    smartish_custom_memo || "DONATION FROM #{donation.smart_memo}#{donation.refunded? ? " (REFUNDED)" : ""}"
  end

  def partner_donation
    @partner_donation ||= PartnerDonation.find_by(id: hcb_i2) if partner_donation?
  end

  def partner_donation_memo
    smartish_custom_memo || "DONATION FROM #{partner_donation.smart_memo}#{partner_donation.refunded? ? " (REFUNDED)" : ""}"
  end

  def ach_transfer
    @ach_transfer ||= AchTransfer.find_by(id: hcb_i2) if ach_transfer?
  end

  def ach_transfer_memo
    smartish_custom_memo || "ACH TO #{ach_transfer.smart_memo}"
  end

  def check
    @check ||= Check.find_by(id: hcb_i2) if check?
  end

  def check_memo
    smartish_custom_memo || "CHECK TO #{check.smart_memo}"
  end

  def disbursement
    @disbursement ||= Disbursement.find_by(id: hcb_i2) if disbursement?
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
    return nil unless ct&.custom_memo || pt&.custom_memo
    return ct.custom_memo unless ct&.custom_memo.blank? || ct&.custom_memo.include?("FEE REFUND")
    return pt.custom_memo unless pt&.custom_memo.blank?

    ct2.custom_memo
  end

  def receipt_required?
    if type == :card_charge && !pt.declined?
      true
    else
      false
    end
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def generate_and_set_short_code
    self.short_code = ::HcbCodeService::Generate::ShortCode.new.run
  end

  # delete this method once preload is on by default
  def not_admin_only_comments_count
    return @not_admin_only_comments_count if defined?(@not_admin_only_comments_count)

    @not_admin_only_comments_count = comments.not_admin_only.count
  end

end
