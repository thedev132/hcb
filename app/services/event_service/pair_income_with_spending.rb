# frozen_string_literal: true

module EventService
  class PairIncomeWithSpending
    def initialize(event:)
      @event = event
      @income = {}
      @current_index = 0
    end

    def run
      negative = @event.canonical_transactions.includes(local_hcb_code: [:canonical_transactions, :canonical_pending_transactions])
                       .order("date asc").filter_map do |ct|
        if ct.amount_cents > 0
          @income[ct.id.to_s] = {
            id: ct.id,
            memo: ct.local_hcb_code.memo,
            amount: ct.amount_cents,
            spent_on: [],
            available: ct.amount_cents
          }
          next
        end

        ct
      end

      negative.each do |ct|
        distribute_spending_to_income(ct:)
      end
      @income
    end

    def distribute_spending_to_income(ct:)
      distributed = 0
      while distributed < ct.amount_cents.abs
        return unless @income.keys[@current_index]

        available_on_current = current[:available]
        # the piece of income at the current index has enough space for the rest that needs to be distributed.
        to_distribute = ct.amount_cents.abs - distributed
        if available_on_current > to_distribute
          current[:spent_on].append(
            {
              id: ct.id,
              memo: ct.local_hcb_code.memo,
              url: Rails.application.routes.url_helpers.hcb_code_url(ct.local_hcb_code),
              amount: to_distribute
            }
          )
          current[:available] -= to_distribute
          distributed += to_distribute
        # the piece of income only has space for some of what still needs to be distributed.
        # as much as possible will be distributed to this piece, and then we will move to the next piece of income.
        else
          current[:spent_on].append(
            {
              id: ct.id,
              memo: ct.local_hcb_code.memo,
              amount: available_on_current
            }
          )
          distributed += available_on_current
          current[:available] = 0
          @current_index += 1
        end
      end
    end

    def current
      @income[@income.keys[@current_index]]
    end

  end
end
