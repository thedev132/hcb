# frozen_string_literal: true

class AddPayoutFieldsToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :payout_creation_queued_at, :datetime
    add_column :invoices, :payout_creation_queued_for, :datetime
    add_column :invoices, :payout_creation_queued_job_id, :text
    add_index :invoices, :payout_creation_queued_job_id, unique: true
    add_column :invoices, :payout_creation_balance_available_at, :datetime
  end
end
