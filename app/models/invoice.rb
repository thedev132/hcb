# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_paper_trail

  extend FriendlyId
  include AASM
  include Commentable

  include PgSearch::Model
  pg_search_scope :search_description, associated_against: { sponsor: :name }, against: [:item_description], using: { tsearch: { prefix: true, dictionary: "english" } }, ranked_by: "invoices.created_at"

  scope :unarchived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :missing_fee_reimbursement, -> { where(fee_reimbursement_id: nil) }
  scope :missing_payout, -> { where("payout_id is null and payout_creation_balance_net is not null") } # some invoices are missing a payout but it is ok because they were paid by check. that is why we additionally check on payout_creation_balance_net
  scope :unpaid, -> { where("aasm_state != 'paid_v2'") }
  scope :past_due, -> { where("due_date < ?", Time.current) }

  friendly_id :slug_text, use: :slugged

  # Raise this when attempting to do an operation with the associated Stripe
  # charge, but it doesn't exist, like in the case of trying to create a payout
  # for an invoice that was so low that no charge was created on Stripe's end
  # (ex. for $0.10).
  class NoAssociatedStripeCharge < StandardError; end

  belongs_to :sponsor
  accepts_nested_attributes_for :sponsor

  belongs_to :creator, class_name: "User"
  belongs_to :manually_marked_as_paid_user, class_name: "User", required: false
  belongs_to :payout, class_name: "InvoicePayout", required: false
  belongs_to :fee_reimbursement, required: false
  belongs_to :archived_by, class_name: "User", required: false

  has_one_attached :manually_marked_as_paid_attachment

  aasm do
    state :open_v2, initial: true
    state :paid_v2
    state :void_v2

    event :mark_paid do
      transitions from: :open_v2, to: :paid_v2
    end

    event :mark_void do
      transitions from: :open_v2, to: :void_v2
    end
  end

  enum status: {
    draft: "draft", # only 3 invoices [203, 204, 128] leftover from when drafts existed
    open: "open",
    paid: "paid",
    void: "void"
  }

  validates_presence_of :item_description, :item_amount, :due_date

  validate :due_date_cannot_be_in_past, on: :create

  validates :item_amount, numericality: { greater_than_or_equal_to: 100 }

  before_create :set_defaults

  # Stripe syncing…
  before_create :create_stripe_invoice
  before_destroy :close_stripe_invoice

  #after_update :send_payment_notification_if_needed # turn off temporarily

  def event
    sponsor.event
  end

  def fee_reimbursed?
    !fee_reimbursement.nil?
  end

  def manually_marked_as_paid?
    manually_marked_as_paid_at.present?
  end

  def payout_transaction
    self&.payout&.t_transaction
  end

  def completed_deprecated?
    (payout_transaction && !self&.fee_reimbursement) || (payout_transaction && self&.fee_reimbursement&.t_transaction) || manually_marked_as_paid?
  end

  def archived?
    archived_at.present?
  end

  def deposited? # TODO move to aasm
    canonical_transactions.count >= 2 || manually_marked_as_paid? || completed_deprecated?
  end

  def state
    return :success if paid_v2? && deposited?
    return :info if paid_v2?
    return :error if void_v2?
    return :error if due_date < Time.current
    return :warning if due_date < 3.days.from_now

    :muted
  end

  def state_text
    return "Deposited" if paid_v2? && deposited?
    return "Paid & Depositing" if paid_v2?
    return "Voided" if void_v2?
    return "Overdue" if due_date < Time.current
    return "Due soon" if due_date < 3.days.from_now

    "Sent"
  end

  def state_deprecated
    if completed_deprecated?
      :success
    elsif paid?
      :info
    elsif archived?
      :pending
    elsif due_date < Time.current
      :error
    elsif due_date < 3.days.from_now
      :warning
    else
      :muted
    end
  end

  def state_text_deprecated
    if completed_deprecated?
      "Paid"
    elsif paid?
      "Pending"
    elsif archived?
      "Archived"
    elsif due_date < Time.current
      "Overdue"
    elsif due_date < 3.days.from_now
      "Due soon"
    else
      "Sent"
    end
  end

  def state_icon
    "checkmark" if state_text == "Paid"
  end

  def filter_data
    {
      exists: true,
      paid: paid?,
      unpaid: !paid?,
      upcoming: due_date > 3.days.from_now,
      overdue: due_date < 3.days.from_now && !paid?,
      archived: archived?
    }
  end

  def set_fields_from_stripe_invoice(inv)
    self.amount_due = inv.amount_due
    self.amount_paid = inv.amount_paid
    self.amount_remaining = inv.amount_remaining
    self.attempt_count = inv.attempt_count
    self.attempted = inv.attempted
    self.auto_advance = inv.auto_advance
    self.due_date = Time.at(inv.due_date).to_datetime # convert from unixtime
    self.ending_balance = inv.ending_balance
    self.finalized_at = inv.finalized_at
    self.hosted_invoice_url = inv.hosted_invoice_url
    self.invoice_pdf = inv.invoice_pdf
    self.livemode = inv.livemode
    self.memo = inv.description
    self.number = inv.number
    self.starting_balance = inv.starting_balance
    self.statement_descriptor = inv.statement_descriptor
    self.status = inv.status
    self.stripe_charge_id = inv&.charge&.id
    self.subtotal = inv.subtotal
    self.tax = inv.tax
    self.tax_percent = inv.tax_percent
    self.total = inv.total
    # https://stripe.com/docs/api/charges/object#charge_object-payment_method_details
    self.payment_method_type = type = inv&.charge&.payment_method_details&.type
    return unless self.payment_method_type

    details = inv&.charge&.payment_method_details[self.payment_method_type]
    return unless details

    if type == "card"
      self.payment_method_card_brand = details.brand
      self.payment_method_card_checks_address_line1_check = details.checks.address_line1_check
      self.payment_method_card_checks_address_postal_code_check = details.checks.address_postal_code_check
      self.payment_method_card_checks_cvc_check = details.checks.cvc_check
      self.payment_method_card_country = details.country
      self.payment_method_card_exp_month = details.exp_month
      self.payment_method_card_exp_year = details.exp_year
      self.payment_method_card_funding = details.funding
      self.payment_method_card_last4 = details.last4
    elsif type == "ach_credit_transfer"
      self.payment_method_ach_credit_transfer_bank_name = details.bank_name
      self.payment_method_ach_credit_transfer_routing_number = details.routing_number
      self.payment_method_ach_credit_transfer_account_number = details.account_number
      self.payment_method_ach_credit_transfer_swift_code = details.swift_code
    end
  end

  def stripe_dashboard_url
    url = "https://dashboard.stripe.com"

    url += "/test" if StripeService.mode == :test

    url += "/invoices/#{self.stripe_invoice_id}"

    url
  end

  def arrival_date
    self&.payout&.arrival_date || 3.business_days.after(payout_creation_queued_for)
  end

  def arriving_late?
    DateTime.now > self.arrival_date
  end

  def stripe_obj
    @stripe_invoice_obj ||= StripeService::Invoice.retrieve(stripe_invoice_id).to_hash
  end

  def remote_invoice
    @remote_invoice ||= ::Partners::Stripe::Invoices::Show.new(id: stripe_invoice_id).run
  end

  def remote_status
    remote_invoice.status
  end

  def remote_paid?
    remote_status == "paid"
  end

  def canonical_pending_transaction
    canonical_pending_transactions.first
  end

  def smart_memo
    sponsor.name.upcase
  end

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(hcb_code: hcb_code)
  end

  def canonical_pending_transactions
    return [] unless raw_pending_invoice_transaction

    @canonical_pending_transactions ||= ::CanonicalPendingTransaction.where(raw_pending_invoice_transaction_id: raw_pending_invoice_transaction)
  end

  def sync_remote!
    self.set_fields_from_stripe_invoice(remote_invoice)
    self.save!
  end

  private

  def raw_pending_invoice_transaction
    raw_pending_invoice_transactions.first
  end

  def raw_pending_invoice_transactions
    @raw_pending_invoice_transactions ||= ::RawPendingInvoiceTransaction.where(invoice_transaction_id: id)
  end

  def set_defaults
    event = sponsor.event.name
    self.memo = "To support #{event}. #{event} is fiscally sponsored by The Hack Foundation (d.b.a. Hack Club), a 501(c)(3) nonprofit with the EIN 81-2908499."

    self.auto_advance = true
  end

  def due_date_cannot_be_in_past
    if due_date.present? && due_date < Time.current
      errors.add(:due_date, "can't be in the past")
    end
  end

  def create_stripe_invoice
    item = StripeService::InvoiceItem.create(stripe_invoice_item_params)
    self.item_stripe_id = item.id

    inv = StripeService::Invoice.create(stripe_invoice_params)
    self.stripe_invoice_id = inv.id

    inv.send_invoice

    self.set_fields_from_stripe_invoice(inv)
  end

  def close_stripe_invoice
    invoice = StripeService::Invoice.retrieve(stripe_invoice_id)
    invoice.void_invoice

    self.set_fields_from_stripe_invoice invoice
  end

  def send_payment_notification_if_needed
    return unless saved_changes[:status].present?

    was = saved_changes[:status][0] # old value of status
    now = saved_changes[:status][1] # new value of status

    if was != "paid" && now == "paid"
      # send special email on first invoice paid
      if self.sponsor.event.invoices.select { |i| i.status == "paid" }.count == 1
        InvoiceMailer.with(invoice: self).first_payment_notification.deliver_later
        return
      end

      InvoiceMailer.with(invoice: self).payment_notification.deliver_later
    end
  end

  def stripe_invoice_item_params
    {
      customer: self.sponsor.stripe_customer_id,
      currency: "usd",
      description: self.item_description,
      amount: self.item_amount
    }
  end

  def stripe_invoice_params
    {
      customer: self.sponsor.stripe_customer_id,
      auto_advance: self.auto_advance,
      billing: "send_invoice",
      due_date: self.due_date.to_i, # convert to unixtime
      description: self.memo,
      status: self.status,
      statement_descriptor: self.statement_descriptor || "HACK CLUB BANK",
      tax_percent: self.tax_percent,
      footer: "\n\n\n\n\n"\
              "Need to pay by mailed paper check?\n\n"\
              "Please pay the amount to the order of The Hack Foundation, and include '#{self.sponsor.event.name} (##{self.sponsor.event.id})' in the memo. Checks can be mailed to:\n\n"\
              "#{self.sponsor.event.name} (##{self.sponsor.event.id}) c/o The Hack Foundation\n"\
              "8605 Santa Monica Blvd #86294\n"\
              "West Hollywood, CA 90069"
    }
  end

  def slug_text
    "#{self.sponsor.name} #{self.item_description}"
  end
end
