# frozen_string_literal: true

module BankFeeJob
  class Weekly < ApplicationJob
    queue_as :low
    def perform
      BankFeeService::Weekly.new.run
    end

  end
end
