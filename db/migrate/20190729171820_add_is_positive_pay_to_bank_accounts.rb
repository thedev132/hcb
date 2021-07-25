# frozen_string_literal: true

class AddIsPositivePayToBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :is_positive_pay, :boolean
  end
end
