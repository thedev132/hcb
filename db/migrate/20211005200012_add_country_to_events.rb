# frozen_string_literal: true

class AddCountryToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :country, :integer
  end
end
