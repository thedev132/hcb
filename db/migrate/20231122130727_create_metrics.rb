# frozen_string_literal: true

class CreateMetrics < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    create_table :metrics do |t|
      t.string :type, null: false
      t.jsonb :metric
      t.timestamps
    end
    add_reference :metrics, :subject, polymorphic: true, index: { algorithm: :concurrently }, optional: true
  end

end
