module TempJob
  class SyncReceiptsNightly < ApplicationJob
    def perform
      ::Temp::SyncReceipts::Nightly.new.run
    end
  end
end
