# frozen_string_literal: true

class AddDemoModeOnEvents < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured {
      add_column :events, :demo_mode, :boolean, default: false, null: false
    }
  end

end
