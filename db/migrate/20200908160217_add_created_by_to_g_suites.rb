# frozen_string_literal: true

class AddCreatedByToGSuites < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_reference :g_suites, :created_by, null: true, foreign_key: { to_table: "users" }
    end
  end
end
