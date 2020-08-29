module PopulateService
  module Development
    class Generate
      def initialize
      end

      # TODO: this should grow to replace the need to load PII production data locally
      def run
        create_new_event_with_user!
        create_under_review_g_suite_application!
      end

      private

      def create_new_event_with_user!
        email = "developmentuser1@mailinator.com"

        ActiveRecord::Base.transaction do
          attrs = {
            api_id: 888_888_888,
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

      def create_under_review_g_suite_application!
        email = "underreview@mailinator.com"
        domain = "underreview.com"
    
        ActiveRecord::Base.transaction do
          attrs = {
            api_id: 999_999_999,
            api_access_token: "token-underreview",
            email: email,
            admin_at: Time.now.utc
          }
          user = User.create!(attrs)

          attrs = {
            point_of_contact: user,
            name: "Under Review Event",
            sponsorship_fee: "100.00",
            slug: "underreviewevent",
          }
          event = Event.create!(attrs)

          attrs = {
            creator: user,
            event: event,
            domain: domain
          }
          g_suite_application = GSuiteApplication.create!(attrs)

          puts "-" * 10
          puts "GSuiteApplication: #{g_suite_application.id}"

          g_suite_application
        end
      end
    end
  end
end
