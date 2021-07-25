# frozen_string_literal: true

class CreateExports < ActiveRecord::Migration[5.2]
  def change
    create_table :exports do |t|
      t.text :type
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :exports, :type
  end
end
