# frozen_string_literal: true

class AddTransactionEngineV2AtToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :transaction_engine_v2_at, :datetime
  end
end
