# frozen_string_literal: true

class AddDepositOnlyToColumnAccountNumbers < ActiveRecord::Migration[7.0]
  def change
    add_column :column_account_numbers, :deposit_only, :boolean, null: false, default: true
  end

end
