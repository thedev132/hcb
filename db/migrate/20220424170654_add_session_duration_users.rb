# frozen_string_literal: true

class AddSessionDurationUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :session_duration_seconds, :integer, default: 30.days.to_i, null: false
  end

end
