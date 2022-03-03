# frozen_string_literal: true

class AddPeacefullyExpiredToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :peacefully_expired, :boolean, default: nil, null: true
  end

end
