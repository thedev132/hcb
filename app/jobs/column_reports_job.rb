# frozen_string_literal: true

class ColumnReportsJob < ApplicationJob
  queue_as :low
  def perform
    ColumnService.post(
      "/reporting",
      from_date: Date.today.prev_month.beginning_of_month.iso8601,
      to_date: Date.today.prev_month.end_of_month.iso8601,
      type: "bank_account_transaction"
    )
  end

end
