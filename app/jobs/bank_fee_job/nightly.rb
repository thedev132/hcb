# frozen_string_literal: true

module BankFeeJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      BankFeeService::Nightly.new.run
    end

  end
end
