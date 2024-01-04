# frozen_string_literal: true

module StripeCardholderService
  class DateOfBirthAgeRestrictedExtractor
    def initialize(user:)
      @user = user
    end

    def run
      return nil unless @user.birthday
      # We don't want to share the dob for users under 13
      # https://github.com/hackclub/hcb/pull/3071#issuecomment-1268880804
      # https://github.com/hackclub/hcb/issues/2775#issuecomment-1823071757
      return nil if @user.birthday > 13.years.ago

      {
        day: @user.birthday.day,
        month: @user.birthday.month,
        year: @user.birthday.year
      }
    end

  end
end
