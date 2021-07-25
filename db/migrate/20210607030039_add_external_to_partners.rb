# frozen_string_literal: true

class AddExternalToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :external, :boolean, null: false, default: true
  end
end
