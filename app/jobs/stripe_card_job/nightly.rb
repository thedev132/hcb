# frozen_string_literal: true

module StripeCardJob
  class Nightly < ApplicationJob
    def perform
      ::StripeCardService::Nightly.new.run
    end

  end
end
