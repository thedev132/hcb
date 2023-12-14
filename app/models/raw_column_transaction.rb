# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_column_transactions
#
#  id                 :bigint           not null, primary key
#  amount_cents       :integer
#  column_transaction :jsonb
#  date_posted        :date
#  description        :text
#  transaction_index  :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  column_report_id   :string
#
class RawColumnTransaction < ApplicationRecord
  has_one :canonical_transaction, as: :transaction_source

  after_create :canonize, if: -> { canonical_transaction.nil? }

  def canonize
    create_canonical_transaction!(
      amount_cents:,
      memo:,
      date: date_posted,
    )
  end

  def memo
    transaction_id = column_transaction["transaction_id"]
    if transaction_id.start_with? "acht"
      ach_transfer = ColumnService.new.ach_transfer(transaction_id)

      return "#{ach_transfer["company_name"]} #{ach_transfer["company_entry_description"]}"
    end

    "COLUMN TRANSACTION"
  rescue
    "COLUMN TRANSACTION"
  end

end
