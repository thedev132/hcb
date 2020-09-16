# frozen_string_literal: true

module RawEmburseTransactionJob
  class Imports < ApplicationJob
    def perform
      200.times do |n|
        puts '-' * 20
        puts n

        from = (n * 10).days.ago

        ::RawEmburseTransactionService::Emburse::Import.new(from: from).run
      end
    end
  end
end
