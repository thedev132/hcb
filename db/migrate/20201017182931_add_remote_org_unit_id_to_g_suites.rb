# frozen_string_literal: true

class AddRemoteOrgUnitIdToGSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :g_suites, :remote_org_unit_id, :text
  end
end
