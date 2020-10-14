module TransactionEngine
  module RawEmburseTransactionService
    module Emburse
      class Import
        def initialize(start_date: Time.now - 15.days, end_date: Time.now)
          @start_date = fmt_date start_date
          @end_date = fmt_date end_date
        end

        def run
          emburse_transactions.each do |t|
            ::RawEmburseTransaction.find_or_initialize_by(emburse_transaction_id: t[:id]).tap do |et|
              et.emburse_transaction = t
              et.amount = t[:amount]
              et.date_posted = t[:time]
              et.state = t[:state]
            end.save!
          end

          nil
        end

        private

        def emburse_transactions
          @emburse_transactions ||= ::Partners::Emburse::Transactions::List.new(
                                                        start_date: @start_date,
                                                        end_date:   @end_date
                                                      ).run
        end

        def fmt_date(date)
          unless date.methods.include? :iso8601
            raise ArgumentError.new("Only datetimes are allowed")
          end
          date.iso8601
        end
      end
    end
  end
end
