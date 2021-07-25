# frozen_string_literal: true

class CreateLoadCardRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :load_card_requests do |t|
      t.references :card, foreign_key: true
      t.references :creator, foreign_key: { to_table: :users }
      t.references :fulfilled_by, foreign_key: { to_table: :users }
      t.bigint :load_amount

      t.timestamps
    end
  end
end
