# frozen_string_literal: true

class CreateUserSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, foreign_key: true
      t.text :session_token

      t.timestamps
    end
  end
end
