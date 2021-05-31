module EventMappingEngine
  class Nightly
    include ::TransactionEngine::Shared

    def initialize(start_date: nil)
      @start_date = start_date || last_1_month
    end

    def run
      #map_historical_plaid! # DEPRECATED - 2021-05-07
      #map_historical_emburse! # DEPRECATED - 2021-05-07
      map_stripe_transactions!
      map_github!
      map_checks!
      map_clearing_checks!
      map_achs!
      map_disbursements!
      map_hack_club_bank_issued_cards!
      map_stripe_top_ups!

      map_bank_fees! # TODO: move to using hcb short codes

      map_hcb_codes_invoice!
      map_hcb_codes_donation!

      map_hcb_codes_short!

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

    def map_clearing_checks!
      ::EventMappingEngine::Map::ClearingChecks.new.run
    end

    def map_achs!
      ::EventMappingEngine::Map::Achs.new.run
    end

    def map_bank_fees!
      ::EventMappingEngine::Map::BankFees.new.run
    end

    def map_disbursements!
      ::EventMappingEngine::Map::Disbursements.new.run
    end

    def map_hack_club_bank_issued_cards!
      ::EventMappingEngine::Map::HackClubBankIssuedCards.new.run
    end

    def map_stripe_top_ups!
      ::EventMappingEngine::Map::StripeTopUps.new.run
    end

    def map_hcb_codes_invoice!
      ::EventMappingEngine::Map::HcbCodes::Invoice.new.run
    end

    def map_hcb_codes_donation!
      ::EventMappingEngine::Map::HcbCodes::Donation.new.run
    end

    def map_hcb_codes_short!
      ::EventMappingEngine::Map::HcbCodes::Short.new.run
    end
  end
end
