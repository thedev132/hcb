# frozen_string_literal: true

class AddSlugToSponsors < ActiveRecord::Migration[5.2]
  def change
    add_column :sponsors, :slug, :text
    add_index :sponsors, :slug, unique: true
  end
end
