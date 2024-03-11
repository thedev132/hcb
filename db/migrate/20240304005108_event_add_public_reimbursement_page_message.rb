class EventAddPublicReimbursementPageMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :public_reimbursement_page_message, :text
  end
end
