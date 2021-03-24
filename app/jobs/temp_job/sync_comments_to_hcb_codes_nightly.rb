module TempJob
  class SyncCommentsToHcbCodesNightly < ApplicationJob
    def perform
      ::Temp::SyncCommentsToHcbCodes::Nightly.new.run
    end
  end
end
