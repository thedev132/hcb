# frozen_string_literal: true

class RemoveIsSpendOnlyOnEvents < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured {
      remove_column :events, :is_spend_only, :boolean
    }
  end
end
