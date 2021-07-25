# frozen_string_literal: true

class AddSyncFieldsToEmburseTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :emburse_transactions, :merchant_mid, :bigint
    add_column :emburse_transactions, :merchant_mcc, :integer
    add_column :emburse_transactions, :merchant_name, :text
    add_column :emburse_transactions, :merchant_address, :text
    add_column :emburse_transactions, :merchant_city, :text
    add_column :emburse_transactions, :merchant_state, :text
    add_column :emburse_transactions, :merchant_zip, :text
    add_column :emburse_transactions, :category_emburse_id, :text
    add_column :emburse_transactions, :category_url, :text
    add_column :emburse_transactions, :category_code, :text
    add_column :emburse_transactions, :category_name, :text
    add_column :emburse_transactions, :category_parent, :text
    add_column :emburse_transactions, :label, :text
    add_column :emburse_transactions, :location, :text
    add_column :emburse_transactions, :note, :text
    add_column :emburse_transactions, :receipt_url, :text
    add_column :emburse_transactions, :receipt_filename, :text
    add_column :emburse_transactions, :transaction_time, :datetime
  end
end
