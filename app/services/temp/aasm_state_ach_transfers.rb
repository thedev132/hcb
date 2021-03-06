module Temp
  class AasmStateAchTransfers
    def run
      AchTransfer.pending_deprecated.each do |a|
        a.aasm_state = "pending"
        a.save!
      end

      AchTransfer.rejected_deprecated.each do |a|
        a.aasm_state = "rejected"
        a.save!
      end

      AchTransfer.approved.each do |a|
        a.aasm_state = "in_transit"
        a.save!
      end

      AchTransfer.approved.each do |a|
        a.aasm_state = "in_transit"
        a.save!
      end

      AchTransfer.in_transit_deprecated.each do |a|
        a.aasm_state = "in_transit"
        a.save!
      end

      AchTransfer.delivered.each do |a|
        a.aasm_state = "deposited"
        a.save!
      end
    end
  end
end
