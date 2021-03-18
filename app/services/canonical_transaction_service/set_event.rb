module CanonicalTransactionService
  class SetEvent
    def initialize(canonical_transaction_id:, event_id:, user:)
      @canonical_transaction_id = canonical_transaction_id
      @event_id = event_id
      @user = user
    end

    def run
      ActiveRecord::Base.transaction do
        if canonical_transaction.canonical_event_mapping
          canonical_transaction.canonical_event_mapping.fees.destroy_all
          canonical_transaction.canonical_event_mapping.destroy! 
        end

        canonical_event_mapping = CanonicalEventMapping.create!(attrs) if event

        attrs = {
          canonical_transaction: canonical_transaction,
          canonical_event_mapping: canonical_event_mapping,
          user: @user
        }
        ::SystemEventService::Write::SettledTransactionMapped.new(attrs).run
      end

      canonical_transaction
    end

    private

    def event
      @event ||= ::Event.find_by(id: @event_id)
    end

    def attrs
      {
        canonical_transaction_id: canonical_transaction.id,
        event_id: event.try(:id),
        user_id: @user.try(:id)
      }
    end

    def canonical_transaction
      @canonical_transaction ||= CanonicalTransaction.find(@canonical_transaction_id)
    end
  end
end
