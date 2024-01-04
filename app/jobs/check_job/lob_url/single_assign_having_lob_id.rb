# frozen_string_literal: true

module CheckJob
  module LobUrl
    class SingleAssignHavingLobId < ApplicationJob
      queue_as :low
      def perform(check:)
        CheckService::LobUrl::SingleAssignHavingLobId.new(check:).run
      end

    end
  end
end
