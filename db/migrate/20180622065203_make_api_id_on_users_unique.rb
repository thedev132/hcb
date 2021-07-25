# frozen_string_literal: true

class MakeApiIdOnUsersUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :api_id, unique: true
  end
end
