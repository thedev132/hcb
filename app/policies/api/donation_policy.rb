# frozen_string_literal: true

module Api
  class DonationPolicy < ApplicationPolicy
    def show?
      !record.pending? && record.event.is_public?
    end

  end

end
