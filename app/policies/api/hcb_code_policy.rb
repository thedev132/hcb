# frozen_string_literal: true

module Api
  class HcbCodePolicy < ApplicationPolicy
    def show?
      record.events.any? { |event| event.is_public? }
    end

  end

end
