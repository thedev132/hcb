# frozen_string_literal: true

module EventService
  class PartnerInviteUser
    def initialize(partner:, event:, user_email:)
      @partner = partner
      @event = event
      @user_email = user_email
    end

    def run
      Airbrake.notify("EventService::PartnerInviteUser ran")
    end

  end
end
