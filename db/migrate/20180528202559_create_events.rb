# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.text :name
      t.datetime :start
      t.datetime :end
      t.text :address
      t.decimal :sponsorship_fee

      t.timestamps
    end
  end
end
