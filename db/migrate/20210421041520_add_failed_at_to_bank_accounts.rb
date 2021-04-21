class AddFailedAtToBankAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_accounts, :failed_at, :datetime
    add_column :bank_accounts, :failure_count, :integer, default: 0
  end
end
