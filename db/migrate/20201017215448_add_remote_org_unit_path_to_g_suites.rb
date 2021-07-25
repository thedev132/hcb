# frozen_string_literal: true

class AddRemoteOrgUnitPathToGSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :g_suites, :remote_org_unit_path, :text
  end
end
