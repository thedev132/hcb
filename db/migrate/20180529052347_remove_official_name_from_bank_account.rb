# frozen_string_literal: true

class RemoveOfficialNameFromBankAccount < ActiveRecord::Migration[5.2]
  def change
    remove_column :bank_accounts, :official_name, :text
  end
end
