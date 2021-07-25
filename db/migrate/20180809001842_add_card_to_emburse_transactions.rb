# frozen_string_literal: true

class AddCardToEmburseTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :emburse_transactions, :emburse_card_id, :string
    add_reference :emburse_transactions, :card, foreign_key: true
  end
end
