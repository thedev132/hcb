# frozen_string_literal: true

module OneTimeJobs
  class RemoveAllPartnerAssociations < ApplicationJob
    def perform
      Event.with_deleted.update_all(partner_id: nil)
    end

  end
end
