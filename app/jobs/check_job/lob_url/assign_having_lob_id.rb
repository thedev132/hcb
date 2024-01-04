# frozen_string_literal: true

module CheckJob
  module LobUrl
    class AssignHavingLobId < ApplicationJob
      queue_as :low
      def perform
        CheckService::LobUrl::AssignHavingLobId.new.run
      end

    end
  end
end
