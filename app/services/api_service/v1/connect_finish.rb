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
        ActiveRecord::Base.transaction do
          event.update_columns(attrs)

          ::UserService::Create.new(user_attrs).run

          event.mark_pending!

          # Send webhook to let Partner know that the Connect from has been submitted
          ::PartneredSignupJob::DeliverWebhook.perform_later(@partnered_signup.id)
        end

        event
      end

      private

      def user_attrs
        {
          event_id: event.id,
          email: @email,
          full_name: @name,
          phone_number: @phone
        }
      end

      def attrs
        {
          name: @organization_name,
          point_of_contact_id: point_of_contact.id,
          owner_name: @name,
          owner_email: @email,
          owner_phone: @phone,
          owner_address: @address,
          owner_birthdate: @birthdate
        }
      end

      def event
        @event ||= Event.find(@event_id)
      end

      def melanie_smith_user_id
        2046
      end

      def point_of_contact
        @point_of_contact ||= ::User.find(melanie_smith_user_id)
      end
    end
  end
end
