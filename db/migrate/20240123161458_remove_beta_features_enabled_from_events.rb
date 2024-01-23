# frozen_string_literal: true

class RemoveBetaFeaturesEnabledFromEvents < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :events, :beta_features_enabled, :boolean }
  end

end
