module TempJob
  class SyncCustomMemosNightly < ApplicationJob
    def perform
      ::Temp::SyncCustomMemos::Nightly.new.run
    end
  end
end
