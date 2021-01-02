# frozen_string_literal: true

module FeeJob
  class Monthly < ApplicationJob
    def perform
      FeeService::Monthly.new.run
    end
  end
end
