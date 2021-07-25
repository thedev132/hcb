# frozen_string_literal: true

class FixGSuiteApplicationRelation < ActiveRecord::Migration[5.2]
  def change
    rename_column :g_suite_applications, :g_suites_id, :g_suite_id
  end
end
