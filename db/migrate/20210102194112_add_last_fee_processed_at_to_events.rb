# frozen_string_literal: true

class AddLastFeeProcessedAtToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :last_fee_processed_at, :datetime
  end
end
