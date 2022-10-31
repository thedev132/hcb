# frozen_string_literal: true

module FeeEngine
  class Hourly
    def run
      CanonicalEventMapping.missing_fee.find_each(batch_size: 100) do |cem|
        FeeEngine::Create.new(canonical_event_mapping: cem).run
      end
    end

  end
end
