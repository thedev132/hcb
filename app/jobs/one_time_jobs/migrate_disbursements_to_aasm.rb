# frozen_string_literal: true

# See https://github.com/hackclub/bank/pull/3061

module OneTimeJobs
  class MigrateDisbursementsToAasm < ApplicationJob
    def perform
      Disbursement.all.each do |disbursement|
        if disbursement.fulfilled?
          disbursement.update(aasm_state: :deposited)
        elsif disbursement.processed?
          disbursement.update(aasm_state: :in_transit)
        elsif disbursement.pending?
          disbursement.update(aasm_state: :pending)
        elsif disbursement.reviewing?
          disbursement.update(aasm_state: :reviewing)
        elsif disbursement.errored?
          disbursement.update(aasm_state: :errored)
        elsif disbursement.rejected?
          disbursement.update(aasm_state: :rejected)
        end
      end
    end

  end
end
