class InvoicePayout < ApplicationRecord
  # Stripe provides a field called type, which is reserved in rails for STI.
  # This removes the Rails reservation on 'type' for this class.
  self.inheritance_column = nil

  # find invoice payouts that don't yet have an associated transaction
  scope :lacking_transaction, -> { includes(:t_transaction).where(transactions: { invoice_payout_id: nil }) }

  # although it normally doesn't make sense for a paynot not to be linked to an invoice,
  # Stripe's schema makes this possible, and when that happens, requiring invoice<>payout breaks bank
  has_one :invoice, inverse_of: :payout, foreign_key: :payout_id
  has_one :t_transaction, class_name: 'Transaction'

  after_initialize :default_values
  before_create :create_stripe_payout
  after_create :notify_organizers

  def set_fields_from_stripe_payout(payout)
    self.amount = payout.amount
    self.arrival_date = Util.unixtime(payout.arrival_date)
    self.automatic = payout.automatic
    self.stripe_balance_transaction_id = payout.balance_transaction
    self.stripe_created_at = Util.unixtime(payout.created)
    self.currency = payout.currency
    self.description = payout.description
    self.stripe_destination_id = payout.destination
    self.failure_stripe_balance_transaction_id = payout.failure_balance_transaction
    self.failure_code = payout.failure_code
    self.failure_message = payout.failure_message
    self.method = payout.method
    self.source_type = payout.source_type
    self.statement_descriptor = payout.statement_descriptor
    self.status = payout.status
    self.type = payout.type
  end

  # Description when displaying a payout in a form dropdown for associating
  # transactions.
  include ApplicationHelper # for render_money helper
  def dropdown_description
    "##{self.id} (#{render_money self.amount}, #{self.invoice&.sponsor&.event&.name}, inv ##{self.invoice&.id} for #{self.invoice&.sponsor&.name})"
  end

  def hcb_code
    invoice.hcb_code
  end

  private

  def default_values
    return unless invoice

    self.statement_descriptor ||= hcb_code

    #self.statement_descriptor ||= "Payout #{self.invoice.sponsor.name}"[0...StripeService::StatementDescriptorCharLimit]
    #                              .gsub(/[^0-9a-z ]/i, '') # alphanumeric only
    #                              .upcase
  end

  def create_stripe_payout
    payout = StripeService::Payout.create(stripe_payout_params)
    self.stripe_payout_id = payout.id

    self.set_fields_from_stripe_payout(payout)
  end

  def notify_organizers
    InvoicePayoutsMailer.with(payout: self).notify_organizers.deliver_later
  end

  def stripe_payout_params
    {
      amount: self.amount,
      currency: 'usd',
      description: self.description,
      destination: self.stripe_destination_id,
      method: self.method,
      source_type: self.source_type,
      statement_descriptor: self.statement_descriptor
    }
  end
end
