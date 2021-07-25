# frozen_string_literal: true

module Partners
  module Lob
    module Checks
      class Create
        include ::Partners::Lob::Shared

        def initialize(to:, memo:, amount_cents:,
                       description:, message:,
                       send_date: nil)
          @to = to
          @memo = memo
          @amount_cents = amount_cents

          @description = description
          @message = message
          @send_date = send_date
        end

        def run
          @run ||= client.checks.create(create_attrs)
        end

        private

        def create_attrs
          {
            to: @to,
            amount: amount,
            memo: short_memo,

            message: @message,
            description: @description,

            send_date: send_date,

            # from shared
            bank_account: bank_account,
            from: from_address
          }.compact
        end

        def short_memo
          @memo[0..40]
        end

        def amount
          @amount ||= @amount_cents / 100.0
        end

        def send_date
          return nil unless @send_date

          @send_date.iso8601
        end
      end
    end
  end
end
