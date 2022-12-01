# frozen_string_literal: true

class CreateTwilioMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :twilio_messages do |t|
      t.text :from
      t.text :to
      t.text :body
      t.text :twilio_sid
      t.text :twilio_account_sid
      t.jsonb :raw_data

      t.timestamps
    end
  end

end
