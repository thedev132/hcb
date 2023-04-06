# frozen_string_literal: true

class DropSeleniumSessions < ActiveRecord::Migration[7.0]
  def change
    drop_table :selenium_sessions
  end

end
