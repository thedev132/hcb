# frozen_string_literal: true

class RemoveCardNumberAndCvvFromCards < ActiveRecord::Migration[5.2]
  def change
    remove_column :cards, :card_number, :string
    remove_column :cards, :cvv, :string
  end
end
