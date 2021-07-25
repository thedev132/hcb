# frozen_string_literal: true

class CreateGSuiteApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :g_suite_applications do |t|
      t.references :creator, index: true, foreign_key: {to_table: :users}
      t.references :event, index: true, foreign_key: true
      t.references :fulfilled_by, index: true, foreign_key: {to_table: :users}
      t.text :domain
      t.timestamp :rejected_at
      t.timestamp :accepted_at
      t.timestamp :canceled_at

      t.timestamps
    end
  end
end
