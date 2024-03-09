# frozen_string_literal: true

class OrganizerPosition
  module HasRole
    extend ActiveSupport::Concern
    included do
      # The enum values will allow us to have a hierarchy of roles in the future.
      # For example, managers have access to everything below them.
      enum :role, { member: 25, manager: 100 }
      validate :at_least_one_manager
    end

    private

    def at_least_one_manager
      event&.organizer_positions&.where(role: :manager)&.any?
    end
  end

end
