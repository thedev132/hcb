# frozen_string_literal: true

class CreateOutgoingTwilioMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :outgoing_twilio_messages do |t|
      t.references :twilio_message
      t.references :hcb_code

      t.timestamps
    end
  end

end
