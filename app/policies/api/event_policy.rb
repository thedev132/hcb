# frozen_string_literal: true

module Api
  class EventPolicy < ApplicationPolicy
    def show?
      record.is_public?
    end

    def transactions?
      record.is_public?
    end

    def donations?
      record.is_public?
    end

    def transfers?
      record.is_public?
    end

    def invoices?
      record.is_public?
    end

    def ach_transfers?
      record.is_public?
    end

    def checks?
      record.is_public?
    end

  end
end
