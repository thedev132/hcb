# frozen_string_literal: true

class RemoveInvalidFieldsFromTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :payment_meta_payee_name, :text
  end
end
