class Transaction < ApplicationRecord
  default_scope { order(date: :desc) }
  belongs_to :bank_account
end
