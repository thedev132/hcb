# frozen_string_literal: true

module OneTimeJobs
  class BackFillReceiptTextualContent < ApplicationJob
    def perform
      Receipt.find_each(batch_size: 100) do |r|
        r.extract_textual_content! if r.textual_content.nil?
      end
    end

  end
end
