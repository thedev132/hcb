# frozen_string_literal: true

module OneTimeJobs
  class ManuallyDeclineCheck < ApplicationJob
    def perform
      check = Check.find_by check_number: 55179
      check.local_hcb_code.canonical_pending_transactions.each(&:decline!)
      check.update_column :aasm_state, :canceled
    end

  end
end
