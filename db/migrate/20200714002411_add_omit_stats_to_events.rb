# frozen_string_literal: true

class AddOmitStatsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :omit_stats, :boolean, default: false
  end
end
