# frozen_string_literal: true

class CreateOpsCheckins < ActiveRecord::Migration[5.2]
  def change
    create_table :ops_checkins do |t|
      t.references :point_of_contact, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
