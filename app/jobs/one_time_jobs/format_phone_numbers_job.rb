# frozen_string_literal: true

module OneTimeJobs
  class FormatPhoneNumbersJob < ApplicationJob
    def perform
      User.where.not(full_name: nil).map do |user|
        puts "Formatting user ##{user.id}"
        formatted_number = Phonelib.parse(user.phone_number).full_e164
        next if formatted_number.blank?

        User.find(user.id).update_column(:phone_number, formatted_number)
      end
    end

  end
end
