class SyncEmburseCardsJob < ApplicationJob
  RUN_EVERY = 30.seconds
  CHUNK_SIZE = 50

  def perform(repeat = false, update_all = false, offset_index = 0)
    offset_index = 0 if offset_index > EmburseCard.all.size
    emburse_cards_to_update = if update_all 
      EmburseCard.all
    else
      EmburseCard.limit(CHUNK_SIZE).offset(offset_index)
    end
    puts "Syncing emburse_cards #{emburse_cards_to_update.pluck :id}"
    emburse_cards_to_update.each do |emburse_card|
      emburse_card.sync_from_emburse!
      emburse_card.save!
    rescue EmburseClient::NotFoundError
      # (max) if the emburse_card doesn't exist on emburse, just mark it as
      # 'terminated' and skip. figuring out how these exist in the first place
      # (hypothetically they shouldn't) is a quest for another day
      emburse_card.emburse_state = 'terminated'
      emburse_card.save!
    end

    self.class.set(wait: RUN_EVERY).perform_later(true, update_all, offset_index + CHUNK_SIZE) if repeat
  end
end
