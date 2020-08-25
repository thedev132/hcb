class OneTimePopulateGSuiteAasmState < ActiveRecord::Migration[6.0]
  def up
    ::OneTimeJob::PopulateGSuiteAasmStateJob.perform_later
  end

  def down
  end
end
