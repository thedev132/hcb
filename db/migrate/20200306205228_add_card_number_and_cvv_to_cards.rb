# frozen_string_literal: true

class AddCardNumberAndCvvToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :card_number, :string
    add_column :cards, :cvv, :string
  end
end
