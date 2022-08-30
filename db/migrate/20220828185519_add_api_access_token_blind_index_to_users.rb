# frozen_string_literal: true

class AddApiAccessTokenBlindIndexToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :users, :api_access_token_bidx, :string
    add_index :users, :api_access_token_bidx, unique: true, algorithm: :concurrently
  end

end
