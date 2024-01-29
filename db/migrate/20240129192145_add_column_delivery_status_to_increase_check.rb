# frozen_string_literal: true

class AddColumnDeliveryStatusToIncreaseCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :column_delivery_status, :string
  end

end
