# frozen_string_literal: true

class RawPendingStripeTransactionDecorator < SimpleDelegator
  include MoneyRails::ActionViewExtension

  def currency
    stripe_transaction["merchant_currency"].upcase
  end

  def original_amount
    txs = stripe_transaction["transactions"] + stripe_transaction["request_history"]

    amount = txs.pluck("merchant_amount").first
    currency = txs.pluck("merchant_currency").first

    Money.new amount.abs, currency
  end

  def original_amount_international
    "#{humanized_money_with_symbol original_amount} #{original_amount.currency}"
  end

end
