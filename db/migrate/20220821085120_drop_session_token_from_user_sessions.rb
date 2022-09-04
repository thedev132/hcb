# frozen_string_literal: true

class DropSessionTokenFromUserSessions < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :user_sessions, :session_token
    end
  end

end
