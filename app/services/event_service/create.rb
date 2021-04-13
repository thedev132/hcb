module EventService
  class Create
    def initialize(name:, emails:[], spend_only: false)
      @name = name
      @emails = emails
      @spend_only = spend_only || false
    end

    def run
      raise ArgumentError, "name required" unless @name.present?
      raise ArgumentError, "spend_only must be true or false" unless (@spend_only === true || @spend_only === false)

      ActiveRecord::Base.transaction do
        event = ::Event.create!(attrs)

        @emails.each do |email|
          event.organizer_position_invites.create!(organizer_attrs(email: email))
        end
      end
    end

    private

    def organizer_attrs(email:)
      {
        sender: point_of_contact,
        email: email,
      }
    end

    def attrs
      {
        name: @name,
        start: Date.current,
        end: Date.current,
        address: "N/A",
        sponsorship_fee: 0.07,
        expected_budget: 100.0,
        has_fiscal_sponsorship_document: true,
        point_of_contact_id: point_of_contact.id,
        is_spend_only: @spend_only
      }
    end

    def melanie_smith_user_id
      2046
    end

    def point_of_contact
      @point_of_contact ||= ::User.find(melanie_smith_user_id)
    end
  end
end
