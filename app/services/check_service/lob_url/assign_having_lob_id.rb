# frozen_string_literal: true

module CheckService
  module LobUrl
    class AssignHavingLobId
      def run
        checks.each do |check|
          lob_url = ::CheckService::LobUrl::Generate.new(check: check).run

          check.update_column(:lob_url, lob_url) 
        end
      end

      private

      def checks
        @checks ||= Check.where("lob_id is not null")
      end
    end
  end
end
