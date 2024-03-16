# frozen_string_literal: true

# == Schema Information
#
# Table name: reimbursement_expenses
#
#  id                      :bigint           not null, primary key
#  aasm_state              :string
#  amount_cents            :integer          default(0), not null
#  approved_at             :datetime
#  description             :text
#  expense_number          :integer          default(1), not null
#  memo                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  approved_by_id          :bigint
#  reimbursement_report_id :bigint           not null
#
# Indexes
#
#  index_reimbursement_expenses_on_approved_by_id           (approved_by_id)
#  index_reimbursement_expenses_on_reimbursement_report_id  (reimbursement_report_id)
#
# Foreign Keys
#
#  fk_rails_...  (approved_by_id => users.id)
#  fk_rails_...  (reimbursement_report_id => reimbursement_reports.id)
#
module Reimbursement
  class Expense < ApplicationRecord
    belongs_to :report, inverse_of: :expenses, foreign_key: "reimbursement_report_id", touch: true
    monetize :amount_cents
    validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
    has_one :expense_payout
    has_one :event, through: :report
    attribute :expense_number, :integer, default: 0
    include AASM
    include Receiptable

    scope :complete, -> { where.not(memo: nil, amount_cents: 0) }

    aasm do
      state :pending, initial: true
      state :approved

      event :mark_approved do
        transitions from: :pending, to: :approved
        after do
          ReimbursementMailer.with(report: self.report, expense: self).expense_approved.deliver_later
        end
      end

      event :mark_pending do
        transitions from: :approved, to: :pending
        after do
          ReimbursementMailer.with(report: self.report, expense: self).expense_unapproved.deliver_later
        end
      end
    end

    validates :expense_number, uniqueness: { scope: :reimbursement_report_id }

    before_validation do
      if self.expense_number == 0
        self.expense_number = self.report.expense_number + 1
        self.report.expense_number += 1
        self.report.save!
      end
    end

    def receipt_required?
      true
    end

    def marked_no_or_lost_receipt_at
      nil
    end

    def missing_receipt?
      # Method needs to be defined for receiptable
      true
    end

    def rejected?
      report.rejected? || pending? && report.closed?
    end

    delegate :locked?, to: :report

    def status_color
      return "muted" if pending? && report.draft?
      return "primary" if rejected?
      return "warning" if pending?

      "success"
    end

  end
end
