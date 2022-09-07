# frozen_string_literal: true

module PendingTransactionEngine
  module PendingTransaction
    class All
      def initialize(event_id:, search: nil, tag_id: nil)
        @event_id = event_id
        @search = search
        @tag_id = tag_id
      end

      def run
        canonical_pending_transactions
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def canonical_pending_event_mappings
        @canonical_pending_event_mappings ||= CanonicalPendingEventMapping.where(event_id: event.id)
      end

      def canonical_pending_transactions
        @canonical_pending_transactions ||=
          begin
            cpts = CanonicalPendingTransaction.includes(:raw_pending_stripe_transaction)
                                              .unsettled
                                              .where(id: canonical_pending_event_mappings.pluck(:canonical_pending_transaction_id))
                                              .order("date desc, canonical_pending_transactions.id desc")

            if @tag_id
              cpts =
                cpts.joins("LEFT JOIN hcb_codes ON hcb_codes.hcb_code = canonical_pending_transactions.hcb_code")
                    .joins("LEFT JOIN hcb_codes_tags ON hcb_codes_tags.hcb_code_id = hcb_codes.id")
                    .where("hcb_codes_tags.tag_id = ?", @tag_id)
            end

            if event.can_front_balance?
              cpts = cpts.not_fronted
            end

            cpts = cpts.search_memo(@search) if @search.present?
            cpts
          end
      end

    end
  end
end
