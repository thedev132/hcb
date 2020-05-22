class SyncEmburseCardsJob < ApplicationJob
  RUN_EVERY = 5.minutes

  def perform(repeat = false)
    Card.all.each do |card|
      puts card.emburse_id
      card.sync_from_emburse!
      card.save!
    rescue EmburseClient::NotFoundError
      # (max) if the card doesn't exist on emburse, just mark it as
      # 'terminated' and skip. figuring out how these exist in the first place
      # (hypothetically they shouldn't) is a quest for another day
      card.emburse_state = 'terminated'
      card.save!
    end

    self.class.set(wait: RUN_EVERY).perform_later(true) if repeat
  end
end
