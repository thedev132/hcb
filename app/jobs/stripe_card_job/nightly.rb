# frozen_string_literal: true

module StripeCardJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      ::StripeCardService::Nightly.new.run
    end

  end
end
