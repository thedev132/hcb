class RawEmburseTransaction < ApplicationRecord
  monetize :amount_cents

  def memo
    return "#{merchant_name}, Card: #{card_description}, Member: #{member_full_name}" if amount_cents < 0

    "Transfer from #{bank_account_description}"
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
