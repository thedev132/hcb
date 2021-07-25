# frozen_string_literal: true

class AddSlugsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :slug, :text
    add_index :documents, :slug, unique: true
  end
end
