# frozen_string_literal: true

module OneTimeJobs
  class BackfillApprovedBy
    def self.perform
      Reimbursement::Expense.find_each do |expense|
        latest_state_change = expense.versions.reverse.find { |version| version.changeset["aasm_state"]&.first.present? }
        if latest_state_change && latest_state_change.changeset["reimbursement_report_id"]&.first.nil? && latest_state_change.whodunnit
          reviewed_by = User.find_by(id: latest_state_change.whodunnit)
          if reviewed_by != expense.report.user || expense.report.team_review_required?
            expense.update(approved_by: User.find_by(id: latest_state_change.whodunnit))
          end
        end
      end
    end

  end
end
