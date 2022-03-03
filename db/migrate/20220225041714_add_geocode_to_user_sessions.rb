# frozen_string_literal: true

class AddGeocodeToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :latitude, :decimal
    add_column :user_sessions, :longitude, :decimal
  end

end
