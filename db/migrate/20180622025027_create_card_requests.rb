# frozen_string_literal: true

class CreateCardRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :card_requests do |t|
      t.references :creator, foreign_key: { to_table: :users }
      t.references :event, foreign_key: true
      t.references :fulfilled_by, foreign_key: { to_table: :users }
      t.timestamp :fulfilled_at
      t.bigint :daily_limit

      t.timestamps
    end
  end
end
