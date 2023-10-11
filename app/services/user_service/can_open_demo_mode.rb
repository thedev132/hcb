# frozen_string_literal: true

module UserService
  module CanOpenDemoMode
    def can_open_demo_mode?(email_address)
      user = User.find_by_email email_address

      return true if user.nil?

      # Users can only be in 10 demo mode events
      demo_mode_count = 0
      demo_mode_count += user.events.demo_mode.size
      demo_mode_count += OrganizerPositionInvite.includes(:user, :event)
                                                .pending
                                                .where(user:)
                                                .where(event: { demo_mode: true })
                                                .size
      demo_mode_count < 10
    end
  end
end
