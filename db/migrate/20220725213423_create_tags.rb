# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.text :label
      t.text :color

      t.timestamps
    end
  end

end
