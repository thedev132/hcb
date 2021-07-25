# frozen_string_literal: true

class CreateReceipts < ActiveRecord::Migration[6.0]
  def change
    create_table :receipts do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.timestamp :attempted_match_at

      t.timestamps
    end
  end
end
