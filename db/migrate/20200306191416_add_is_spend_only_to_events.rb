# frozen_string_literal: true

class AddIsSpendOnlyToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :is_spend_only, :boolean
  end
end
