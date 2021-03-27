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
  scope :missing_hcb_code, -> { where(hcb_code: nil) }
  scope :missing_or_unknown_hcb_code, -> { where("hcb_code is null or hcb_code ilike 'HCB-000%'") }
  scope :invoice_hcb_code, -> { where("hcb_code ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE}%'") }
  scope :donation_hcb_code, -> { where("hcb_code ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE}%'") }
  scope :ach_transfer_hcb_code, -> { where("hcb_code ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::ACH_TRANSFER_CODE}%'") }
  scope :check_hcb_code, -> { where("hcb_code ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::CHECK_CODE}%'") }
  scope :disbursement_hcb_code, -> { where("hcb_code ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::DISBURSEMENT_CODE}%'") }
  scope :stripe_card_hcb_code, -> { where("hcb_code ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::STRIPE_CARD_CODE}%'") }

  after_create_commit :write_hcb_code
  after_create_commit :write_system_event

  def mapped?
    @mapped ||= canonical_pending_event_mapping.present?
  end
  
  def settled?
    @settled ||= canonical_pending_settled_mappings.exists?
  end

  def declined?
    @declined ||= canonical_pending_declined_mappings.exists?
  end

  def unsettled?
    @unsettled ||= !settled? && !declined?
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

  def ach_transfer
    return linked_object if linked_object.is_a?(AchTransfer)

    nil
  end

  def check
    return linked_object if linked_object.is_a?(Check)

    nil
  end

  def invoice
    return linked_object if linked_object.is_a?(Invoice)

    nil
  end

  def donation
    return linked_object if linked_object.is_a?(Donation)

    nil
  end

  def raw_stripe_transaction
    nil # used by canonical_transaction. necessary to implement as nil given hcb code generation
  end

  def remote_stripe_iauth_id
    raw_pending_stripe_transaction.stripe_transaction_id
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

  def url
    return "/hcb/#{local_hcb_code.hashid}" if local_hcb_code

    "/canonical_pending_transactions/#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_by(hcb_code: hcb_code)
  end

  private

  def write_hcb_code
    safely do
      self.update_column(:hcb_code, ::TransactionGroupingEngine::Calculate::HcbCode.new(canonical_transaction_or_canonical_pending_transaction: self).run)
    end
  end

  def friendly_memo_in_memory_backup
    @friendly_memo_in_memory_backup ||= PendingTransactionEngine::FriendlyMemoService::Generate.new(pending_canonical_transaction: self).run
  end

  def write_system_event
    safely do
      ::SystemEventService::Write::PendingTransactionCreated.new(canonical_pending_transaction: self).run
    end
  end

end
