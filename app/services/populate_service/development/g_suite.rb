module PopulateService
  module Development
    class GSuite
      def initialize
      end

      # TODO: this should grow to replace the need to load PII production data locally
      def run
        create_under_review_g_suite_application!
      end

      private

      def create_under_review_g_suite_application!
        email = "underreview@mailinator.com"
        domain = "underreview.com"
    
        ActiveRecord::Base.transaction do
          attrs = {
            api_id: 999_999_999,
            api_access_token: "token",
            email: email
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
