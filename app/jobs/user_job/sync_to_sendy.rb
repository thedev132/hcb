# frozen_string_literal: true

module UserJob
  class SyncToSendy < ApplicationJob
    # Retry for 1 month (exponentially backoff)
    retry_on Exception, wait: :exponentially_longer, attempts: 26

    def perform(user_id)
      ::UserService::SyncToSendy.new(user_id: user_id, dry_run: false).run
    end

  end
end
