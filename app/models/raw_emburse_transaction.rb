class RawEmburseTransaction < ApplicationRecord
  has_many :hashed_transactions

  monetize :amount_cents

  def memo
    return merchant_description if amount_cents < 0

    "Transfer from #{bank_account_description}"
  end

  def merchant_description
    str = ''
    str += merchant_name if merchant_name.present?
    str += ", Card: #{card_description}" if card_description.present?
    str += ", Member: #{member_full_name}" if member_full_name.present?

    str
  end

  def bank_account_description
    emburse_transaction.dig('bank_account', 'description')
  end

  def merchant_name
    emburse_transaction.dig('merchant', 'name')
  end

  def card_description
    emburse_transaction.dig('card', 'description')
  end

  def member_first_name
    emburse_transaction.dig('member', 'first_name')
  end

  def member_last_name
    emburse_transaction.dig('member', 'last_name')
  end

  def member_full_name
    "#{member_first_name} #{member_last_name}"
  end
end
