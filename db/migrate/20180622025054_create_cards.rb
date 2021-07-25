# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.references :admin, foreign_key: { to_table: :users }
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true
      t.bigint :daily_limit

      t.timestamps
    end
  end
end
