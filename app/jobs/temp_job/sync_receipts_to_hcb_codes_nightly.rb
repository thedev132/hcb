module TempJob
  class SyncReceiptsToHcbCodesNightly < ApplicationJob
    def perform
      ::Temp::SyncReceiptsToHcbCodes::Nightly.new.run
    end
  end
end
