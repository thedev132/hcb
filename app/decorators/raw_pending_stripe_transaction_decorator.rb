# frozen_string_literal: true

class RawPendingStripeTransactionDecorator < SimpleDelegator
  include MoneyRails::ActionViewExtension

  def currency
    stripe_transaction["merchant_currency"].upcase
  end

  def original_amount
    tx = stripe_transaction["transactions"].first
    Money.new tx["merchant_amount"].abs, tx["merchant_currency"]
  end

  def original_amount_international
    "#{humanized_money_with_symbol original_amount} #{original_amount.currency}"
  end

end
