class DropGSuiteApplications < ActiveRecord::Migration[6.0]
  def up
    drop_table :g_suite_applications
  end

  def down
  end
end
