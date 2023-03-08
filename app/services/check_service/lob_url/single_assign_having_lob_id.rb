# frozen_string_literal: true

module CheckService
  module LobUrl
    class SingleAssignHavingLobId
      def initialize(check:)
        @check = check
      end

      def run
        raise ArgumentError, "Check must have a lob_id" unless @check.lob_id.present?

        lob_url = ::CheckService::LobUrl::Generate.new(check: @check).run
        @check.update_column(:lob_url, lob_url)
      end

    end

  end
end
