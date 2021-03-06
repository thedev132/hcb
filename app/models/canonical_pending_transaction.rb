class CanonicalPendingTransaction < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_memo, against: [:memo]

  belongs_to :raw_pending_stripe_transaction, optional: true
  belongs_to :raw_pending_outgoing_check_transaction, optional: true
  belongs_to :raw_pending_outgoing_ach_transaction, optional: true
  belongs_to :raw_pending_donation_transaction, optional: true
  belongs_to :raw_pending_invoice_transaction, optional: true
  has_one :canonical_pending_event_mapping
  has_one :event, through: :canonical_pending_event_mapping
  has_many :canonical_pending_settled_mappings
  has_many :canonical_transactions, through: :canonical_pending_settled_mappings
  has_many :canonical_pending_declined_mappings

  monetize :amount_cents

  scope :safe, -> { where("date >= '2021-01-01'") } # older pending transactions don't yet all map up because of older processes (especially around invoices)

  scope :stripe, -> { where('raw_pending_stripe_transaction_id is not null')}
  scope :incoming, -> { where('amount_cents > 0') }
  scope :outgoing, -> { where('amount_cents < 0') }
  scope :outgoing_ach, -> { where('raw_pending_outgoing_ach_transaction_id is not null')}
  scope :outgoing_check, -> { where('raw_pending_outgoing_check_transaction_id is not null')}
  scope :donation, -> { where('raw_pending_donation_transaction_id is not null')}
  scope :invoice, -> { where('raw_pending_invoice_transaction_id is not null')}
  scope :unmapped, -> { includes(:canonical_pending_event_mapping).where(canonical_pending_event_mappings: {canonical_pending_transaction_id: nil}) }
  scope :mapped, -> { includes(:canonical_pending_event_mapping).where.not(canonical_pending_event_mappings: {canonical_pending_transaction_id: nil}) }
  scope :unsettled, -> { 
    includes(:canonical_pending_settled_mappings).where(canonical_pending_settled_mappings: {canonical_pending_transaction_id: nil})
      .includes(:canonical_pending_declined_mappings).where(canonical_pending_declined_mappings: { canonical_pending_transaction_id: nil })
  }

  def unsettled?
    @unsettled ||= !canonical_pending_settled_mappings.exists? && canonical_pending_declined_mappings.exists?
  end

  def smart_memo
    friendly_memo_in_memory_backup
  end

  def linked_object
    return raw_pending_outgoing_check_transaction.check if raw_pending_outgoing_check_transaction
    return raw_pending_outgoing_ach_transaction.ach_transfer if raw_pending_outgoing_ach_transaction
    return raw_pending_donation_transaction.donation if raw_pending_donation_transaction
    return raw_pending_invoice_transaction.invoice if raw_pending_invoice_transaction

    nil
  end


  # DEPRECATED
  def display_name
    smart_memo
  end

  def name # in deprecated system this is the imported name
    smart_memo
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

  def invoice_payout
    nil # TODO
  end

  def fee_reimbursement
    nil # TODO
  end

  def check
    nil # TODO
  end

  def donation_payout
    nil # TODO
  end

  def fee_applies?
    nil # TODO
  end

  def emburse_transfer
    nil # TODO
  end

  def disbursement
    nil # TODO
  end

  private

  def friendly_memo_in_memory_backup
    @friendly_memo_in_memory_backup ||= PendingTransactionEngine::FriendlyMemoService::Generate.new(pending_canonical_transaction: self).run
  end

end
