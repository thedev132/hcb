# frozen_string_literal: true

class AddUrlHashToRecurringDonations < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :recurring_donations, :url_hash, :text
    add_index :recurring_donations, :url_hash, unique: true, algorithm: :concurrently
  end

end
