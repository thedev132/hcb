module BankFeeService
  class Weekly
    def run
      Event.pending_fees_v2.each do |event|
        BankFeeService::Create.new(event_id: event.id).run
      end

      true
    end
  end
end
