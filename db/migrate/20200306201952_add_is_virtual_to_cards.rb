# frozen_string_literal: true

class AddIsVirtualToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :is_virtual, :boolean
  end
end
