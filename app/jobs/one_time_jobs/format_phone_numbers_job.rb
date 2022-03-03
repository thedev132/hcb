# frozen_string_literal: true

module OneTimeJobs
  class FormatPhoneNumbersJob < ApplicationJob
    def perform
      User.where.not(full_name: nil).map do |user|
        puts "Formatting user ##{user.id}"
        user.send(:format_number)
        user.save!
      end
    end

  end
end
