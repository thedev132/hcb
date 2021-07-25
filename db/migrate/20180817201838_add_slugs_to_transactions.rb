# frozen_string_literal: true

class AddSlugsToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :slug, :text
    add_index :transactions, :slug, unique: true
  end
end
