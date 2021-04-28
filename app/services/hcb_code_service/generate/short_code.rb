# frozen_string_literal: true

module HcbCodeService
  module Generate
    class ShortCode
      ALPHANUMERIC_CHARSET = ("A".."Z").to_a + (0..9).to_a
      KEY_LENGTH = 5 # seems to be limit from Stripe to SVB on payouts

      def run
        short_code = nil

        loop do
          short_code = generate_unique_short_code_candidate

          break unless ::HcbCode.where(short_code: short_code).exists?
        end

        short_code
      end

      private

      def generate_unique_short_code_candidate
        (0...key_length).map{ charset[rand(charset.size)] }.join
      end

      def key_length
        KEY_LENGTH
      end

      def charset
        ALPHANUMERIC_CHARSET
      end
    end
  end
end
