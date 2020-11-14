module Receiptable
  extend ActiveSupport::Concern

  included do
    has_many :receipts, as: :receiptable

    scope :without_receipt, -> { includes(:receipts).where(receipts: { receiptable_id: nil })}
    scope :missing_receipt, -> { without_receipt.where(marked_no_or_lost_receipt_at: nil)}

    def missing_receipt?
      without_receipt? && !no_or_lost_receipt?
    end

    def without_receipt?
      receipts.none?
    end

    def no_or_lost_receipt?
      !marked_no_or_lost_receipt_at.nil?
    end

    def no_or_lost_receipt!
      self.marked_no_or_lost_receipt_at = Time.now
      self.save
      self
    rescue NoMethodError => e
      puts "Add a boolean 'lost_or_no_receipt' column to #{self.class.name} for this to work"
      print_exception(e, true)
    end
  end
end