# frozen_string_literal: true

class AddIpAndSoftDeleteToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :ip, :string
    add_column :user_sessions, :deleted_at, :datetime
  end

end
