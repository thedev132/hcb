# frozen_string_literal: true

module CheckJob
  module LobUrl
    class SingleAssignHavingLobId < ApplicationJob
      def perform(check:)
        CheckService::LobUrl::SingleAssignHavingLobId.new(check: check).run
      end

    end
  end
end
