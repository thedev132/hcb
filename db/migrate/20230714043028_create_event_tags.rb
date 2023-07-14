# frozen_string_literal: true

class CreateEventTags < ActiveRecord::Migration[7.0]
  def change
    create_table :event_tags do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end

end
