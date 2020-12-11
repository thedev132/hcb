module TempFixStripeAuthorizationsJob
  class Nightly < ApplicationJob
    def perform
      ::TempFixStripeAuthorizations::Nightly.new.run
    end
  end
end
