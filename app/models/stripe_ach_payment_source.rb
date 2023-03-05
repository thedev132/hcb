# frozen_string_literal: true

# == Schema Information
#
# Table name: stripe_ach_payment_sources
#
#  id                        :bigint           not null, primary key
#  account_number_ciphertext :text
#  routing_number_ciphertext :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_id                  :bigint           not null
#  stripe_customer_id        :text
#  stripe_source_id          :text
#
# Indexes
#
#  index_stripe_ach_payment_sources_on_event_id          (event_id)
#  index_stripe_ach_payment_sources_on_stripe_source_id  (stripe_source_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
class StripeAchPaymentSource < ApplicationRecord
  belongs_to :event
  has_many :ach_payments

  has_encrypted :account_number, :routing_number

  before_create :create_stripe_source

  def charge!(amount)
    StripeService::Charge.create(
      amount: amount,
      currency: "usd",
      source: self.stripe_source_id,
      customer: self.stripe_customer_id,
      metadata: { event_id: event.id },
    )
  end

  private

  def create_stripe_source
    source = StripeService::Source.create(
      type: "ach_credit_transfer",
      currency: "usd",
      receiver: {
        refund_attributes_method: "manual",
      },
    )

    customer = StripeService::Customer.create(source: source.id)

    self.stripe_source_id = source.id
    self.stripe_customer_id = customer.id
    self.account_number = source.ach_credit_transfer.account_number
    self.routing_number = source.ach_credit_transfer.routing_number
  end

end
