# frozen_string_literal: true

class AddApiKeyBlindIndexToPartners < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :partners, :api_key_bidx, :string
    add_index :partners, :api_key_bidx, unique: true, algorithm: :concurrently
  end

end
