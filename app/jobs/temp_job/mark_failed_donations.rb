module TempJob
  class MarkFailedDonations < ApplicationJob
    def perform
      ::Temp::MarkFailedDonations.new.run
    end
  end
end
