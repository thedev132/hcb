# frozen_string_literal: true

module EventService
  class PartnerInviteUser
    def initialize(partner:, event:, user_email:)
      @partner = partner
      @event = event
      @user_email = user_email
    end

    def run
      user = User.find_or_create_by!(email: @user_email)

      position_exists = @event.users.include?(user)
      invite_exists = @event.organizer_position_invites
                            .pending.where(email: @user_email).any?

      unless position_exists || invite_exists
        OrganizerPositionInviteService::Create.new(
          event: @event,
          sender: @event.partner.representative,
          user_email: @user_email,
        ).run!
      end

      user
    end

  end
end
