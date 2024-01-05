# frozen_string_literal: true

class DropOpsCheckins < ActiveRecord::Migration[7.0]
  def change
    drop_table :ops_checkins
  end

end
