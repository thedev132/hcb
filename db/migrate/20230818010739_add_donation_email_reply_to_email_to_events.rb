# frozen_string_literal: true

class AddDonationEmailReplyToEmailToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :donation_reply_to_email, :text
  end


end
