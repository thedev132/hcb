# frozen_string_literal: true

class RenameCardRequestsToEmburseCardRequests < ActiveRecord::Migration[6.0]
  def change

    rename_table :card_requests, :emburse_card_requests
  end
end
