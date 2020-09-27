module Receiptable
  extend ActiveSupport::Concern

  included do
    has_many :receipts, as: :receiptable
  end
end