# frozen_string_literal: true

module OneTimeJobs
  class FixOrganizerPositionInviteNilUsersJob < ApplicationJob
    def perform
      # create or find users that aren't associated (basically what OrganizerPositionInviteService::Create does now)
      OrganizerPositionInvite.where(user: nil).each do |opi|
        user = User.find_or_create_by!(email: OrganizerPositionInvite.last.email)
        opi.update(user: user)
      end

      fail if OrganizerPositionInvite.where(user: nil).count != 54 # this is how many should be failing the validation error

      # the remaining invites with nil users are failing a validation error
      # confirm that and delete them
      OrganizerPositionInvite.where(user: nil).each do |opi|
        opi.user # try to associate again just to set the errors on the instance
        if opi.errors.full_messages == ["User is already an organizer of this event!"]
          opi.destroy!
        end
      end
    end

  end
end
