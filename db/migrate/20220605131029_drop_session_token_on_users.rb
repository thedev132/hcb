# frozen_string_literal: true

class DropSessionTokenOnUsers < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :users, :session_token
    end
  end

end
