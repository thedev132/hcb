module CheckService
  module PositivePay
    class Csv
      def initialize(check_id:)
        @check_id = check_id
      end

      def run
        CSV.generate(headers: true) do |csv|
          csv << headers.map
          csv << values.map
        end
      end

      private

      def check
        @check ||= Check.find(@check_id)
      end

      def headers
        @headers ||= %w{iv account_number check_number amount date}
      end

      def values
        [
          "I", # for issue (TODO: V for void)
          positive_pay_account_number,
          check.check_number,
          (check.amount.to_f / 100),
          check.created_at.strftime('%m-%d-%Y')
        ]
      end

      def positive_pay_account_number
        Rails.application.credentials.positive_pay_account_number
      end
    end
  end
end
