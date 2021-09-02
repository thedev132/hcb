# frozen_string_literal: true

module MfaCodeService
  module Parsers
    class SVB
      def initialize(message:)
        @message = message
      end

      def run
        code = @message.scan(/SVB code is (\d*)./).first&.first&.strip

        return code unless code.empty?
        nil
      end
    end
  end
end
