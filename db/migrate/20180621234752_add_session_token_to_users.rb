# frozen_string_literal: true

class AddSessionTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :session_token, :text
  end
end
