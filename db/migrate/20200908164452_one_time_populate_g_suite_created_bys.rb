class OneTimePopulateGSuiteCreatedBys < ActiveRecord::Migration[6.0]
  def change
    ::OneTimeJob::PopulateGSuiteCreatedBys.perform_later
  end
end
