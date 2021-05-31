# frozen_string_literal: true

module BankFeeJob
  class Monthly < ApplicationJob
    def perform
      BankFeeService::Monthly.new.run
    end
  end
end
