class OneTimePopulateGSuiteAasmState < ActiveRecord::Migration[6.0]
  def up
    ::OneTimeJob::PopulateGSuiteAasmState.perform_later
  end

  def down
  end
end
