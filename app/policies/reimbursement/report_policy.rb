# frozen_string_literal: true

module Reimbursement
  class ReportPolicy < ApplicationPolicy
    def new?
      admin || team_member
    end

    def create?
      !record.event.demo_mode && (record.event.public_reimbursement_page_enabled? || admin || team_member)
    end

    def show?
      admin || team_member || creator
    end

    def edit?
      admin || team_member || (creator && unlocked)
    end

    def update?
      admin || team_member || (creator && unlocked)
    end

    def submit?
      unlocked && (admin || team_member || creator)
    end

    def draft?
      (admin || team_member || creator) && open
    end

    def request_reimbursement?
      (admin || team_member) && open
    end

    def request_changes?
      (admin || team_member) && open
    end

    def approve_all_expenses?
      (admin || team_member) && open
    end

    def reject?
      (admin || team_member) && open
    end

    def admin_approve?
      admin && open
    end

    def destroy?
      ((team_member || creator) && record.initial_draft?) || (admin && !record.reimbursed?)
    end

    private

    def admin
      user&.admin?
    end

    def team_member
      record.event.users.include?(user)
    end

    def creator
      record.user == user
    end

    def open
      !record.closed?
    end

    def unlocked
      !record.locked?
    end

  end
end
