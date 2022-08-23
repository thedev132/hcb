# frozen_string_literal: true

module PendingTransactionEngine
  module PendingTransaction
    class AssociationPreloader
      def initialize(pending_transactions:, event:)
        @pending_transactions = pending_transactions
        @event = event
      end

      def run!
        preload_associations!
      end

      def preload_associations!
        hcb_code_codes = @pending_transactions.map(&:hcb_code)
        included_models = [:receipts, :comments, :canonical_transactions, :canonical_pending_transactions]
        # rubocop:disable Naming/VariableNumber
        included_models << :tags if Flipper.enabled?(:transaction_tags_2022_07_29, @event)
        # rubocop:enable Naming/VariableNumber

        hcb_code_objects = HcbCode
                           .includes(*included_models)
                           .where(hcb_code: hcb_code_codes)
        hcb_code_by_code = hcb_code_objects.index_by(&:hcb_code)

        hcb_code_objects.each do |hc|
          hc.not_admin_only_comments_count = hc.comments.count { |c| !c.admin_only }
        end

        stripe_ids = @pending_transactions.filter_map do |pt|
          if pt.raw_pending_stripe_transaction
            pt.raw_pending_stripe_transaction.stripe_transaction["cardholder"]
          end
        end
        stripe_cardholders_by_stripe_id = ::StripeCardholder.includes(:user).where(stripe_id: stripe_ids).index_by(&:stripe_id)

        @pending_transactions.each do |pt|
          pt.local_hcb_code = hcb_code_by_code[pt.hcb_code]

          if pt.raw_pending_stripe_transaction
            pt.stripe_cardholder = stripe_cardholders_by_stripe_id[pt.raw_pending_stripe_transaction.stripe_transaction["cardholder"]]
          end
        end
      end

    end
  end
end
