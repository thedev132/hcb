# frozen_string_literal: true

module MfaRequestService
  class Create
    def run
      MfaRequest.create!(attrs)
    end

    private

    def attrs
      {
        provider: "SVB"
      }
    end
  end
end
