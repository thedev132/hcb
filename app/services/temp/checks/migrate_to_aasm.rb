module Temp
  module Checks
    class MigrateToAasm
      def run
        Check.all.each do |check|
          check.update_column(:aasm_state, check.status.to_s)
        end
      end
    end
  end
end
