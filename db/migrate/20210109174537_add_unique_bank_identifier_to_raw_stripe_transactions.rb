# frozen_string_literal: true

class AddUniqueBankIdentifierToRawStripeTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_stripe_transactions, :unique_bank_identifier, :string, null: false
  end
end
