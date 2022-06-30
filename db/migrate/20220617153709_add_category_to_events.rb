# frozen_string_literal: true

class AddCategoryToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :category, :integer
  end

end
