# frozen_string_literal: true

module Api
  module V4
    module ApplicationHelper
      def pagination_metadata(json)
        json.total_count @total_count
        json.has_more @has_more
      end

      def transaction_amount(tx)
        return tx.amount.cents if !tx.is_a?(HcbCode)

        return tx.disbursement.amount if tx.disbursement?
        return tx.donation.amount if tx.donation?
        return tx.invoice.item_amount if tx.invoice?

        return tx.amount.cents
      end

    end
  end
end
