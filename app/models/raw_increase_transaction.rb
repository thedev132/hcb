# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_increase_transactions
#
#  id                      :bigint           not null, primary key
#  amount_cents            :integer
#  date_posted             :date
#  description             :text
#  increase_route_type     :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  increase_account_id     :text
#  increase_route_id       :text
#  increase_transaction_id :text
#
# Indexes
#
#  index_raw_increase_transactions_on_increase_transaction_id  (increase_transaction_id) UNIQUE
#
class RawIncreaseTransaction < ApplicationRecord
  has_many :hashed_transactions

end
