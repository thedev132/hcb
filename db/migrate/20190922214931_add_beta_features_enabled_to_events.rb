# frozen_string_literal: true

class AddBetaFeaturesEnabledToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :beta_features_enabled, :boolean
  end
end
