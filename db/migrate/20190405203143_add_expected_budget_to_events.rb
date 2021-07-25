# frozen_string_literal: true

class AddExpectedBudgetToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :expected_budget, :integer
  end
end
