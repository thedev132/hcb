# frozen_string_literal: true

class ProcessColumnCheckDepositJob < ApplicationJob
  class AmountMismatchError < StandardError; end
  class UnconfidentError < StandardError; end

  def perform(check_deposit:, validate: true)
    raise ArgumentError, "check deposit already processed" if check_deposit.column_id.present? || check_deposit.increase_id.present?

    conn = Faraday.new url: "https://api.column.com" do |f|
      f.request :basic_auth, "", Rails.application.credentials.column.dig(ColumnService::ENVIRONMENT, :api_key)
      f.request :multipart
      f.response :raise_error
      f.response :json
    end

    # Upload front
    front = check_deposit.front.open do |file|
      conn.post("/transfers/checks/image/front", { file: Faraday::Multipart::FilePart.new(file.path, check_deposit.front.content_type) }).body
    end

    raise UnconfidentError, "could not confidently detect amount on check" if validate && front["deposit_amount_confidence"] < 0.8
    raise UnconfidentError, "could not confidently parse payment details from check" if validate && front["micr_line_confidence"] < 0.8

    raise AmountMismatchError, "provided amount was #{check_deposit.amount.format}, but detected amount was #{Money.from_cents(front["deposit_amount"]).format}" if validate && check_deposit.amount_cents.to_s != front["deposit_amount"]

    # Upload back
    back = check_deposit.back.open do |file|
      conn.post("/transfers/checks/image/back", { file: Faraday::Multipart::FilePart.new(file.path, check_deposit.back.content_type) }).body
    end

    column_check_deposit = ColumnService.post("/transfers/checks/deposit", bank_account_id: ColumnService::Accounts::FS_MAIN,
                                                                           account_number_id: Rails.application.credentials.dig(:column, ColumnService::ENVIRONMENT, :default_account_number),
                                                                           deposited_amount: check_deposit.amount_cents,
                                                                           currency_code: "USD",
                                                                           micr_line: front["micr_line"],
                                                                           image_front: front["image_front"],
                                                                           image_back: back["image_back"])

    check_deposit.update!(column_id: column_check_deposit["id"])

    check_deposit

  end

end
