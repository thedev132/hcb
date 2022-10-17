# frozen_string_literal: true

class AddSeasonalThemesEnabledToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :seasonal_themes_enabled, :boolean, null: false, default: true
  end

end
