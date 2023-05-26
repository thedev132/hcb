# frozen_string_literal: true

class CreateSubledgers < ActiveRecord::Migration[7.0]
  def change
    create_table :subledgers do |t|
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end

end
