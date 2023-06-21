# frozen_string_literal: true

module CheckService
  module LobUrl
    class AssignHavingLobId
      def run
        checks.each do |check|
          CheckJob::LobUrl::SingleAssignHavingLobId.perform_later(check:)
        end
      end

      private

      def checks
        @checks ||= Check.where("lob_id is not null")
      end

    end
  end
end
