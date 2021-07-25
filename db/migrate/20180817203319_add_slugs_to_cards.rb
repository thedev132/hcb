# frozen_string_literal: true

class AddSlugsToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :slug, :text
    add_index :cards, :slug, unique: true
  end
end
