module TempJob
  class SyncDonationsAasm < ApplicationJob
    def perform
      ::Temp::SyncDonations::Aasm.new.run
    end
  end
end
