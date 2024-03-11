class EventAddReimbursementPageEnabled < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :public_reimbursement_page_enabled, :boolean, default: false, null: false
  end
end
