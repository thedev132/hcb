# frozen_string_literal: true

class AddMailerQueuedJobIdToFeeReimbursements < ActiveRecord::Migration[5.2]
  def change
    add_column :fee_reimbursements, :mailer_queued_job_id, :string
  end
end
