class SyncEmburseCardsJob < ApplicationJob
  def perform
    EmburseCards.find_each do |emburse_card|
      emburse_card.sync_from_emburse!
      emburse_card.save!
    rescue EmburseClient::NotFoundError
      # (max) if the emburse_card doesn't exist on emburse, just mark it as
      # 'terminated' and skip. figuring out how these exist in the first place
      # (hypothetically they shouldn't) is a quest for another day
      emburse_card.emburse_state = 'terminated'
      emburse_card.save!
    end
  end
end
