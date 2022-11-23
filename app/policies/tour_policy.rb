# frozen_string_literal: true

class TourPolicy < ApplicationPolicy
  def mark_complete?
    record.tourable.user == user
  end

  def set_step?
    record.tourable.user == user
  end

end
