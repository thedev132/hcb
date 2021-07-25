# frozen_string_literal: true

class AddMissingFieldsToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :last_four, :string
    add_column :cards, :full_name, :string
    add_column :cards, :address, :text
    add_column :cards, :expiration_month, :integer
    add_column :cards, :expiration_year, :integer
    add_reference :cards, :card_request, index: true
  end
end
