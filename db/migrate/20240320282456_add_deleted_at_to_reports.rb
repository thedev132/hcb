class AddDeletedAtToReports < ActiveRecord::Migration[7.0]
  def change
    add_column :reimbursement_reports, :deleted_at, :timestamp
  end
end
