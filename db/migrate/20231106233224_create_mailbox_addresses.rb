# frozen_string_literal: true

class CreateMailboxAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :mailbox_addresses do |t|
      t.string :address, null: false
      t.string :aasm_state

      t.belongs_to :user, null: false, foreign_key: true

      t.datetime :discarded_at

      t.timestamps
    end

    add_index :mailbox_addresses, :address, unique: true
  end

end
