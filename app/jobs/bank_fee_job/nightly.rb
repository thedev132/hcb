# frozen_string_literal: true

module BankFeeJob
  class Nightly < ApplicationJob
    def perform
      BankFeeService::Nightly.new.run
    end
  end
end
