module PopulateService
  module Development
    class Generate
      def initialize
      end

      # TODO: this should grow to replace the need to load PII production data locally
      def run
        create_new_event_with_user!
      end

      private

      def create_new_event_with_user!
        email = "developmentuser1@mailinator.com"

        ActiveRecord::Base.transaction do
          attrs = {
            api_access_token: "token-developmentuser1",
            email: email,
            admin_at: Time.now.utc
          }
          user = User.create!(attrs)

          attrs = {
            point_of_contact: user,
            name: "Development Event",
            sponsorship_fee: "100.00",
            slug: "developmentevent"
          }
          event = Event.create!(attrs)

          attrs = {
            user: user,
            event: event
          }
          organizer_position = OrganizerPosition.create!(attrs)

          event
        end
      end
    end
  end
end
