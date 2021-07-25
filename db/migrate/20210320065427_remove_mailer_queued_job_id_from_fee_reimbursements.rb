# frozen_string_literal: true

class RemoveMailerQueuedJobIdFromFeeReimbursements < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :fee_reimbursements, :mailer_queued_job_id, :string
    end
  end
end
