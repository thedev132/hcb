module EventService
  class Create
    def initialize(name:, emails:[], spend_only: false)
      @name = name
      @emails = emails
      @spend_only = spend_only || false
    end

    def run
      Event.create!(attrs)
    end

    private

    def attrs
      {
        name: @name,
        start: Date.current,
        end: Date.current,
        address: "N/A",
        sponsorship_fee: 0.07,
        expected_budget: 100.0,
        has_fiscal_sponsorship_document: true,
        point_of_contact_id: melanie_smith_user_id,
        is_spend_only: @spend_only
      }
    end

    private

    def melanie_smith_user_id
      2046
    end
  end
end
