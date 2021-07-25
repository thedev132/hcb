# frozen_string_literal: true

class AddSlugsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :slug, :text, unique: true
  end
end
