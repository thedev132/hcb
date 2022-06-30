# frozen_string_literal: true

class AddInitialPasswordCiphertextToGSuiteAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :g_suite_accounts, :initial_password_ciphertext, :text
  end

end
