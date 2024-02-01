# frozen_string_literal: true

module OneTimeJobs
  class BackfillReturnedAchs
    def self.perform
      AchTransfer.where.not(column_id: nil).find_each do |ach|
        puts ach.id
        column_ach = ColumnService.ach_transfer(ach.column_id)
        if column_ach["status"] == "RETURNED"
          ach.update!(aasm_state: "failed")
        end
      end
    end

  end
end
