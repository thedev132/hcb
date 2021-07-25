# frozen_string_literal: true

module BankFeeJob
  class Weekly < ApplicationJob
    def perform
      BankFeeService::Weekly.new.run
    end
  end
end
