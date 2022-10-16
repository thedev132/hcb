# frozen_string_literal: true

module OneTimeJobs
  class SubscribeSendy < ApplicationJob
    def perform
      User.find_each(batch_size: 100) do |user|
        UserJob::SyncToSendy.perform_later(user.id)
      end
    end

  end
end
