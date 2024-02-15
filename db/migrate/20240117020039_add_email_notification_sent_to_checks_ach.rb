class AddEmailNotificationSentToChecksAch < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :send_email_notification, :boolean, default: false
    add_column :ach_transfers, :send_email_notification, :boolean, default: false
  end
end
