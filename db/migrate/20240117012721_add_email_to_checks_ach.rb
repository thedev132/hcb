class AddEmailToChecksAch < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :recipient_email, :string
    add_column :ach_transfers, :recipient_email, :string
  end
end
