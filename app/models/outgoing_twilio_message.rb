# frozen_string_literal: true

# == Schema Information
#
# Table name: outgoing_twilio_messages
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  hcb_code_id       :bigint
#  twilio_message_id :bigint
#
# Indexes
#
#  index_outgoing_twilio_messages_on_hcb_code_id        (hcb_code_id)
#  index_outgoing_twilio_messages_on_twilio_message_id  (twilio_message_id)
#
class OutgoingTwilioMessage < ApplicationRecord
  belongs_to :twilio_message
  belongs_to :hcb_code, required: false

  validates_presence_of :twilio_message

end
