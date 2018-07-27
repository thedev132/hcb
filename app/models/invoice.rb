class Invoice < ApplicationRecord
  # Raise this when attempting to do an operation with the associated Stripe
  # charge, but it doesn't exist, like in the case of trying to create a payout
  # for an invoice that was so low that no charge was created on Stripe's end
  # (ex. for $0.10).
  class NoAssociatedStripeCharge < StandardError; end

  belongs_to :sponsor
  belongs_to :creator, class_name: 'User'
  belongs_to :manually_marked_as_paid_user, class_name: 'User', required: false
  belongs_to :payout, class_name: 'InvoicePayout', required: false

  has_one_attached :manually_marked_as_paid_attachment

  validates_presence_of :item_description, :item_amount, :due_date

  # all manually_marked_as_paid_... fields must be present all together or not
  # present at all
  validates_presence_of :manually_marked_as_paid_user, :manually_marked_as_paid_reason,
    if: -> { !self.manually_marked_as_paid_at.nil? }
  validates_absence_of :manually_marked_as_paid_user, :manually_marked_as_paid_reason,
    if: -> { self.manually_marked_as_paid_at.nil? }

  # all payout_creation... fields must be present all together or not at all
  validates_presence_of :payout_creation_queued_for,
    :payout_creation_queued_job_id, :payout_creation_balance_available_at,
    if: -> { !self.payout_creation_queued_at.nil? }
  validates_absence_of :payout_creation_queued_for,
    :payout_creation_queued_job_id, :payout_creation_balance_available_at,
    if: -> { self.payout_creation_queued_at.nil? }

  validate :due_date_cannot_be_in_past, on: :create

  before_create :set_memo

  # Stripe syncing...
  before_create :create_stripe_invoice
  before_destroy :close_stripe_invoice

  # Manually mark this invoice as paid (probably in the case of a physical
  # check being sent to pay it). This marks the corresponding payment on Stripe
  # as paid and stores some metadata about why it was marked as paid.
  def manually_mark_as_paid(user_who_did_it, reason_for_manual_payment, attachment=nil)
    self.manually_marked_as_paid_at = Time.current
    self.manually_marked_as_paid_user = user_who_did_it
    self.manually_marked_as_paid_reason = reason_for_manual_payment
    self.manually_marked_as_paid_attachment = attachment

    return false unless self.valid?

    inv = StripeService::Invoice.retrieve(stripe_invoice_id)
    inv.paid = true

    if inv.save 
      self.set_fields_from_stripe_invoice(inv)

      if self.save
        true
      else
        false
      end
    else
      errors.add(:base, 'failed to save with vendor')

      false
    end
  end

  def manually_marked_as_paid?
    self.manually_marked_as_paid_at.present?
  end

  def paid?
    self.paid
  end

  def queue_payout!
    inv = StripeService::Invoice.retrieve(id: stripe_invoice_id, expand: ['charge.balance_transaction'])
    raise NoAssociatedStripeCharge if inv.charge.nil?

    b_tnx = inv.charge.balance_transaction

    funds_available_at_unixtime = b_tnx.available_on
    funds_available_at = Time.at(funds_available_at_unixtime) # parse unixtime

    create_payout_at = funds_available_at + 1.hour

    job = CreateInvoicePayoutJob.set(wait_until: create_payout_at).perform_later(self)

    self.payout_creation_queued_at = Time.current
    self.payout_creation_queued_for = create_payout_at
    self.payout_creation_queued_job_id = job.job_id
    self.payout_creation_balance_available_at = funds_available_at

    self.save!
  end

  def create_payout!
    inv = StripeService::Invoice.retrieve(id: stripe_invoice_id, expand: ['charge.balance_transaction'])
    amount = inv.charge.balance_transaction.net

    raise StandardError, 'Funds not yet available' unless Time.current.to_i > inv.charge.balance_transaction.available_on

    self.payout = InvoicePayout.new(
      amount: amount
    )

    self.save!
  end

  def set_fields_from_stripe_invoice(inv)
    self.amount_due = inv.amount_due,
    self.amount_paid = inv.amount_paid
    self.amount_remaining = inv.amount_remaining
    self.attempt_count = inv.attempt_count
    self.attempted = inv.attempted
    self.stripe_charge_id = inv.charge
    self.closed = inv.closed
    self.memo = inv.description
    self.due_date = Time.at(inv.due_date).to_datetime # convert from unixtime
    self.ending_balance = inv.ending_balance
    self.forgiven = inv.forgiven
    self.hosted_invoice_url = inv.hosted_invoice_url
    self.invoice_pdf = inv.invoice_pdf
    self.paid = inv.paid
    self.starting_balance = inv.starting_balance
    self.statement_descriptor = inv.statement_descriptor
    self.subtotal = inv.subtotal
    self.tax = inv.tax
    self.tax_percent = inv.tax_percent
    self.total = inv.total
  end

  def stripe_dashboard_url
    url = 'https://dashboard.stripe.com'

    if StripeService.mode == :test
      url += '/test'
    end

    url += "/invoices/#{self.stripe_invoice_id}"
    
    url
  end

  private

  def set_memo
    event = self.sponsor.event.name
    self.memo = "To support #{event}. #{event} is fiscally sponsored by The Hack Foundation (d.b.a. Hack Club), a 501(c)(3) nonprofit with the EIN 81-2908499."
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

    self.set_fields_from_stripe_invoice(inv)
  end

  def close_stripe_invoice
    invoice = StripeService::Invoice.retrieve(stripe_invoice_id)
    invoice.closed = true
    invoice.save
    self.set_fields_from_stripe_invoice invoice
  end

  def stripe_invoice_item_params
    {
      customer: self.sponsor.stripe_customer_id,
      currency: 'usd',
      description: self.item_description,
      amount: self.item_amount
    }
  end

  def stripe_invoice_params
    {
      customer: self.sponsor.stripe_customer_id,
      billing: 'send_invoice',
      due_date: self.due_date.to_i, # convert to unixtime
      description: self.memo,
      statement_descriptor: self.statement_descriptor,
      tax_percent: self.tax_percent
    }
  end
end
