class AddEventToLoadCardRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :load_card_requests, :event, foreign_key: true

    LoadCardRequest.all.each do |lcr|
      lcr.event_id = lcr.card.event_id
      lcr.save!
    end
  end
end
