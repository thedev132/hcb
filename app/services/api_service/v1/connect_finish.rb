# frozen_string_literal: true

module ApiService
  module V1
    class ConnectFinish
      def initialize(event_id:,
                     organization_name:, organization_url:,
                     name:, email:, phone:, address:, birthdate:)
        @event_id = event_id
        @organization_name = organization_name
        @organization_url = organization_url
        @name = name
        @email = email
        @phone = phone
        @address = address
        @birthdate = birthdate
      end

      def run
        event.update_column(:name, @organization_name)
        event.update_column(:point_of_contact_id, point_of_contact.id)

        event.organizer_position_invites.create!(organizer_attrs)

        event
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def melanie_smith_user_id
        2046
      end

      def point_of_contact
        @point_of_contact ||= ::User.find(melanie_smith_user_id)
      end

      def organizer_attrs
        {
          sender: point_of_contact,
          email: @email
        }
      end
    end
  end
end

