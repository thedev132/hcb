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
      when "SVBFSOPERATING" # SVB FS OPERATING
        "SVBFSOPERATING" # used to handle special case of some ACH transfers going out under the wrong bank account
      when 9
        "HACKFOUNDATION5667" # FS CHECK ESCROW
      when 11
        "HACKFOUNDATION5667" # FS CHECK ESCROW - new plaid connection from scottm
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
