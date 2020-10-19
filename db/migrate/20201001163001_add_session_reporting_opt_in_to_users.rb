class AddSessionReportingOptInToUsers < ActiveRecord::Migration[6.0]
  def up
    # Create the new column with "false" default so existing users aren't
    # opted-in accidentally
    add_column :users, :sessions_reported, :boolean, default: false, null: false

    # Change the default to "true" so new users are automatically opted-in
    change_column_default :users, :sessions_reported, true
  end

  def down
    remove_column :users, :sessions_reported
  end
end
