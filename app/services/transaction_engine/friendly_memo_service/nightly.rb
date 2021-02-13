module TransactionEngine
  module FriendlyMemoService
    class Nightly
      def run
        Event.all.pluck(:id).each do |event_id|
          ::TransactionEngine::FriendlyMemoService::AssignAllForEvent.new(event_id: event_id).run
        end
      end
    end
  end
end
