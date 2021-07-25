# frozen_string_literal: true

class CreateGSuites < ActiveRecord::Migration[5.2]
  def change
    create_table :g_suites do |t|
      t.text :domain
      t.references :event, foreign_key: true
      t.text :verification_key
      t.timestamp :deleted_at

      t.timestamps
    end
    add_reference :g_suite_applications, :g_suites, foreign_key: true
  end
end
