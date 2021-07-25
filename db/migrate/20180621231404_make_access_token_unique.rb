# frozen_string_literal: true

class MakeAccessTokenUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :api_access_token, unique: true
  end
end
