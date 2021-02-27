module EventMappingEngine
  class Nightly
    include ::TransactionEngine::Shared

    def initialize(start_date: nil)
      @start_date = start_date || last_1_month
    end

    def run
      map_historical_plaid!
      map_historical_emburse!
      map_stripe_transactions!
      map_github!
      map_checks!
      map_fee_reimbursements!
      map_hack_club_bank_issued_cards!
      map_stripe_top_ups!

      true
    end

    private

    def map_historical_plaid!
      ::EventMappingEngine::Map::HistoricalPlaid.new(start_date: @start_date).run
    end

    def map_historical_emburse!
      ::EventMappingEngine::Map::HistoricalEmburse.new(start_date: @start_date).run
    end

    def map_stripe_transactions!
      ::EventMappingEngine::Map::StripeTransactions.new(start_date: @start_date).run
    end

    def map_github!
      ::EventMappingEngine::Map::Github.new.run
    end

    def map_checks!
      ::EventMappingEngine::Map::Checks.new.run
    end

    def map_fee_reimbursements!
      ::EventMappingEngine::Map::FeeReimbursements.new.run
    end

    def map_hack_club_bank_issued_cards!
      ::EventMappingEngine::Map::HackClubBankIssuedCards.new.run
    end

    def map_stripe_top_ups!
      ::EventMappingEngine::Map::StripeTopUps.new.run
    end
  end
end
