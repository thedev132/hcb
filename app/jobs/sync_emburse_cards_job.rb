class SyncEmburseCardsJob < ApplicationJob
  RUN_EVERY = 30.seconds
  CHUNK_SIZE = 50

  def perform(repeat = false, update_all = false, offset_index = 0)
    offset_index = 0 if offset_index > Card.all.size
    cards_to_update = if update_all 
      Card.all
    else
      Card.limit(CHUNK_SIZE).offset(offset_index)
    end
    puts "Syncing cards #{cards_to_update.pluck :id}"
    cards_to_update.each do |card|
      card.sync_from_emburse!
      card.save!
    rescue EmburseClient::NotFoundError
      # (max) if the card doesn't exist on emburse, just mark it as
      # 'terminated' and skip. figuring out how these exist in the first place
      # (hypothetically they shouldn't) is a quest for another day
      card.emburse_state = 'terminated'
      card.save!
    end

    self.class.set(wait: RUN_EVERY).perform_later(true, update_all, offset_index + CHUNK_SIZE) if repeat
  end
end
