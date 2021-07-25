# frozen_string_literal: true

class FeeReimbursement < ApplicationRecord
  include Commentable

  has_one :invoice, required: false
  has_one :donation, required: false
  has_one :t_transaction, class_name: "Transaction", inverse_of: :fee_reimbursement

  before_create :default_values

  # SVB has a 30 character limit for transfer descriptions
  validates_length_of :transaction_memo, maximum: 30
  validates_uniqueness_of :transaction_memo

  scope :unprocessed, -> { includes(:t_transaction).where(processed_at: nil, transactions: { fee_reimbursement_id: nil }) }
  scope :pending, -> { includes(:t_transaction).where.not(processed_at: nil).where(transactions: { fee_reimbursement_id: nil }) }
  scope :completed, -> { includes(:t_transaction).where.not(transactions: { fee_reimbursement_id: nil }) }

  def unprocessed?
    processed_at.nil? && t_transaction.nil?
  end

  def pending?
    !processed_at.nil?
  end

  def completed?
    !t_transaction.nil?
  end

  def status
    return "completed" if completed?
    return "pending" if pending?

    "unprocessed"
  end

  def status_color
    return "success" if completed?
    return "info" if pending?

    "error"
  end

  def event
    if donation
      return donation.event
    else
      return invoice.try(:event)
    end
  end

  def payout
    if donation
      return donation.payout
    else
      return invoice.try(:payout)
    end
  end

  def transaction_display_name
    if donation
      return "Fee refund for donation from #{donation.name}"
    else
      return "Fee refund for invoice to #{invoice.sponsor.name}"
    end
  end

  def process
    processed_at = DateTime.now
  end

  def transfer_amount
    [self.amount, 100].max
  end

  def default_values
    if invoice
      self.transaction_memo ||= "HCB-#{invoice.local_hcb_code.short_code}"
      self.amount ||= invoice.item_amount - invoice.payout_creation_balance_net
    else
      self.transaction_memo ||= "HCB-#{donation.local_hcb_code.short_code}"
      self.amount ||= donation.payout_creation_balance_stripe_fee
    end
  end

  def admin_dropdown_description
    "#{ApplicationController.helpers.render_money self.amount} - #{self.transaction_memo} (#{self.event.name})"
  end

  # this needs to exist for the case where amount of reimbursement is less than $1 and we need to do fee weirdness
  def calculate_fee_amount
    if amount < 100
      if invoice.present?
        return (amount * self.invoice.event.sponsorship_fee) + (100 - amount)
      else
        return (amount * self.donation.event.sponsorship_fee) + (100 - amount)
      end
    else
      if invoice.present?
        return amount * self.invoice.event.sponsorship_fee
      else
        return amount * self.donation.event.sponsorship_fee
      end
    end
  end

  def canonical_transaction
    @canonical_transaction ||= event.canonical_transactions.where("memo ilike '#{transaction_memo}%' and date >= ?", created_at - 1.day).first
  end
end
