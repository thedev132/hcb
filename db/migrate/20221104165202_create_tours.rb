# frozen_string_literal: true

class CreateTours < ActiveRecord::Migration[6.1]
  def change
    create_table :tours do |t|
      t.string :name
      t.boolean :active, default: true
      t.references :tourable, polymorphic: true, null: false

      t.timestamps
    end
  end

end
