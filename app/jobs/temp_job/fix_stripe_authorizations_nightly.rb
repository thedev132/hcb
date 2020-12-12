module TempJob
  class FixStripeAuthorizationsNightly < ApplicationJob
    def perform
      ::Temp::FixStripeAuthorizations::Nightly.new.run
    end
  end
end
