module TransactionEngine
  module Shared
    def last_1_month
      Time.now.utc - 1.month
    end

    # WARNING: do not modify these. will have drastic effects. these are used to hash transactions in combination with memo, amount, and date
    def unique_bank_identifier
      case @bank_account_id
      when 1
        "EVENTFISCALSPONSORSHIP"
      when 4
        "FSMAIN"
      when 9
        "HACKFOUNDATION5667"
      when "EMBURSEISSUING1"
        "EMBURSEISSUING1"
      when "STRIPEISSUING1"
        "STRIPEISSUING1"
      else
        raise NotImplementedError, "Implement unique bank identifier for bank account id: #{@bank_account_id}"
      end
    end
  end
end
