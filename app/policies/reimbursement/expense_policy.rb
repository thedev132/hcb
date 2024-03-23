# frozen_string_literal: true

module Reimbursement
  class ExpensePolicy < ApplicationPolicy
    def create?
      unlocked && (admin || team_member || creator)
    end

    def edit?
      unlocked && (admin || team_member || creator)
    end

    def update?
      unlocked && (admin || team_member || creator)
    end

    def destroy?
      unlocked && (admin || team_member || creator)
    end

    def toggle_approved?
      (admin || team_member) && record.report.submitted?
    end

    def user_made_expense?
      record&.report&.user == user
    end

    alias receiptable_upload? user_made_expense?

    private

    def admin
      user&.admin?
    end

    def team_member
      record.event.users.include?(user)
    end

    def creator
      record.report.user == user
    end

    def unlocked
      !record.report.locked?
    end

  end
end
