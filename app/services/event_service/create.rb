module EventService
  class Create
    def initialize(name:, emails:[], has_fiscal_sponsorship_document: false, sponsorship_fee: 0.07)
      @name = name
      @emails = emails
      @has_fiscal_sponsorship_document = has_fiscal_sponsorship_document || false
      @sponsorship_fee = sponsorship_fee ? sponsorship_fee.to_f : 0.07
    end

    def run
      raise ArgumentError, "name required" unless @name.present?
      raise ArgumentError, "has_fiscal_sponsorship_document must be true or false" unless (@has_fiscal_sponsorship_document === true || @has_fiscal_sponsorship_document === false)
      raise ArgumentError, "sponsorship_fee must be 0 to 0.5" unless (@sponsorship_fee >= 0.0 && @sponsorship_fee <= 0.5)

      ActiveRecord::Base.transaction do
        event = ::Event.create!(attrs)
        event.mark_approved!

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
        sponsorship_fee: @sponsorship_fee,
        expected_budget: 100.0,
        has_fiscal_sponsorship_document: @has_fiscal_sponsorship_document,
        point_of_contact_id: point_of_contact.id,
        partner_id: partner.id
      }
    end

    def melanie_smith_user_id
      2046
    end

    def point_of_contact
      @point_of_contact ||= ::User.find(melanie_smith_user_id)
    end

    def partner
      @partner ||= ::Partner.find_by!(slug: "bank")
    end
  end
end
