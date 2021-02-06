module TempJob
  class SyncCommentsNightly < ApplicationJob
    def perform
      ::Temp::SyncComments::Nightly.new.run
    end
  end
end
