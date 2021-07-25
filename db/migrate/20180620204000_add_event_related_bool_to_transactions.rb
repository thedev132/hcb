# frozen_string_literal: true

class AddEventRelatedBoolToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :is_event_related, :boolean
  end
end
