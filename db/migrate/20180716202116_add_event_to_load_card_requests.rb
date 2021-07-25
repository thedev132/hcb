# frozen_string_literal: true

class AddEventToLoadCardRequests < ActiveRecord::Migration[5.2]
  class MigrationLoadCardRequest < ActiveRecord::Base
    self.table_name = :load_card_requests
  end
  class MigrationCard < ActiveRecord::Base
    self.table_name = :cards
  end
  def change
    add_reference :load_card_requests, :event, foreign_key: true

    MigrationLoadCardRequest.find_each do |lcr|
      card = MigrationCard.find_by(card_id: lcr.card_id)
      lcr.update!(event_id: card.event_id)
    end
  end
end
