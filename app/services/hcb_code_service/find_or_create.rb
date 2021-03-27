# frozen_string_literal: true

module HcbCodeService
  class FindOrCreate
    def initialize(hcb_code:)
      @hcb_code = hcb_code
    end

    def run
      ::HcbCode.find_or_initialize_by(hcb_code: @hcb_code).tap do |hc|
      end.save!
    end
  end
end
