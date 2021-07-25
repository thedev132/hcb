# frozen_string_literal: true

class DonationPayout < ApplicationRecord
  # most of this was copied from models/invoice.rb

  # Stripe provides a field called type, which is reserved in rails for STI.
  # This removes the Rails reservation on 'type' for this class.
  self.inheritance_column = nil

  # find donation payouts that don't yet have an associated transaction
  scope :lacking_transaction, -> { includes(:t_transaction).where(transactions: { donation_payout_id: nil }) }
  scope :in_transit, -> { where(status: "in_transit") }
  scope :paid, -> { where(status: "paid") }
  scope :donation_hcb_code, -> { where("statement_descriptor ilike 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE}%'") }

  # although it normally doesn't make sense for a paynot not to be linked to an donation,
  # Stripe's schema makes this possible, and when that happens, requiring donation<>payout breaks bank
  has_one :donation, inverse_of: :payout, foreign_key: :payout_id
  has_one :t_transaction, class_name: "Transaction"

  validates_length_of :statement_descriptor, maximum: 22
  validates_uniqueness_of :statement_descriptor

  after_initialize :default_values
  before_create :create_stripe_payout

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
    "##{self.id} | #{render_money self.amount} (#{self.donation.event.name}, #{self.donation.name})"
  end

  def hcb_code
    donation.hcb_code
  end

  def local_hcb_code
    donation.local_hcb_code
  end

  def event
    donation.event
  end

  private

  def default_values
    return unless donation

    self.statement_descriptor ||= "HCB-#{local_hcb_code.short_code}"
  end

  def create_stripe_payout
    payout = StripeService::Payout.create(stripe_payout_params)
    self.stripe_payout_id = payout.id

    self.set_fields_from_stripe_payout(payout)
  end

  def stripe_payout_params
    {
      amount: self.donation.payout_creation_balance_net,
      currency: "usd",
      description: self.description,
      destination: self.stripe_destination_id,
      method: self.method,
      source_type: self.source_type,
      statement_descriptor: self.statement_descriptor
    }
  end
end
