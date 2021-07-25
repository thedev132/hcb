# frozen_string_literal: true

class AddAdminNotificationTimestampToEmburseTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :emburse_transactions, :notified_admin_at, :timestamp
  end
end
