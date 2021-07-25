# frozen_string_literal: true

class AddNameToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :name, :text
    add_column :partners, :logo, :text
  end
end
