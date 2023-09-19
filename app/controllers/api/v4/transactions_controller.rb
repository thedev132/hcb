# frozen_string_literal: true

module Api
  module V4
    class TransactionsController < ApplicationController
      skip_after_action :verify_authorized, only: [:missing_receipt]

      def missing_receipt
        user_hcb_code_ids = current_user.stripe_cards.flat_map { |card| card.hcb_codes.pluck(:id) }
        user_hcb_codes = HcbCode.where(id: user_hcb_code_ids)

        hcb_codes_missing_ids = user_hcb_codes.missing_receipt.filter(&:receipt_required?).pluck(:id)
        @hcb_codes = HcbCode.where(id: hcb_codes_missing_ids).order(created_at: :desc)

        @total_count = @hcb_codes.size
        @has_more = false # TODO: implement pagination
      end

    end
  end
end
