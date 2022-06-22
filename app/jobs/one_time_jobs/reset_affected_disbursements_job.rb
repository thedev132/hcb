# frozen_string_literal: true

module OneTimeJobs
  class ResetAffectedDisbursementsJob < ApplicationJob
    # https://github.com/hackclub/bank/commit/020b9eda563de4b017790204a2e01eb24a88db9e
    def perform(start_id: 965, end_id: 979)
      (start_id..end_id).each do |id|
        affected_disbursement = Disbursement.find_by_id id

        next if affected_disbursement.nil?
        next unless affected_disbursement.processed?

        affected_disbursement.fulfilled_at = nil
        affected_disbursement.save!
      end

    end

  end
end
