# frozen_string_literal: true

class AddFingerPrintColumnsToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :fingerprint, :string
    add_column :user_sessions, :device_info, :string
    add_column :user_sessions, :os_info, :string
    add_column :user_sessions, :timezone, :string
  end

end
