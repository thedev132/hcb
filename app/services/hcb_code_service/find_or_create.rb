# frozen_string_literal: true

module HcbCodeService
  class FindOrCreate
    def initialize(hcb_code:)
      @hcb_code = hcb_code
    end

    def run
      ::HcbCode.find_or_create_by(hcb_code: @hcb_code)
    end
  end
end
