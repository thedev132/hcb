# frozen_string_literal: true

module UserService
  class Create
    def initialize(event_id:, email:, full_name:, phone_number:)
      @event_id = event_id
      @email = email
      @full_name = full_name
      @phone_number = phone_number
    end

    def run
      organizer_position = find_organizer_position || create_organizer_position!

      organizer_position.user
    end

    private

    def user
      @user ||= find_user || create_user!
    end

    def find_user
      User.where(email: @email).first
    end

    def create_user!
      User.create!(attrs)
    end

    def attrs
      {
        api_access_token: SecureRandom.hex, # TODO: deprecate to decouple from remote auth api
        email: @email,
        full_name: @full_name,
        phone_number: @phone_number
      }
    end

    def find_organizer_position
      OrganizerPosition.where(event: event, user: user).first
    end

    def create_organizer_position!
      OrganizerPosition.create!(organizer_position_attrs)
    end

    def organizer_position_attrs
      {
        event: event,
        user: user
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end
  end
end
