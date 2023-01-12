# frozen_string_literal: true

module PendingTransactionEngine
  module PendingTransaction
    class All
      def initialize(event_id:, search: nil, tag_id: nil, hcb_code_type: nil)
        @event_id = event_id
        @search = search
        @tag_id = tag_id
        @hcb_code_type = hcb_code_type # this is a mess :sob:
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
            included_local_hcb_code_associations = [:receipts, :comments, :canonical_transactions, :canonical_pending_transactions]
            # rubocop:disable Naming/VariableNumber
            included_local_hcb_code_associations << :tags if Flipper.enabled?(:transaction_tags_2022_07_29, @event)
            # rubocop:enable Naming/VariableNumber
            cpts = CanonicalPendingTransaction.includes(:raw_pending_stripe_transaction,
                                                        local_hcb_code: included_local_hcb_code_associations)
                                              .unsettled
                                              .where(id: canonical_pending_event_mappings.pluck(:canonical_pending_transaction_id))
                                              .order("canonical_pending_transactions.date desc, canonical_pending_transactions.id desc")

            if @tag_id
              cpts =
                cpts.joins("LEFT JOIN hcb_codes ON hcb_codes.hcb_code = canonical_pending_transactions.hcb_code")
                    .joins("LEFT JOIN hcb_codes_tags ON hcb_codes_tags.hcb_code_id = hcb_codes.id")
                    .where("hcb_codes_tags.tag_id = ?", @tag_id)
                    .where("hcb_codes.hcb_code = ?", "HCB-#{@hcb_code_type}-%")
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
