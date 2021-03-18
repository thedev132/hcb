module Temp
  module SyncDonations
    class Aasm
      def run
        Donation.find_each(batch_size: 100) do |d|
          d.update_column(:aasm_state, "pending")
          d.update_column(:aasm_state, "in_transit") if d.in_transit_deprecated?
          d.update_column(:aasm_state, "deposited") if d.deposited_deprecated?
        end
      end
    end
  end
end
