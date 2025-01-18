# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_recipients
#
#  id                        :bigint           not null, primary key
#  account_number_ciphertext :text
#  bank_name_ciphertext      :string
#  email                     :text
#  information_ciphertext    :text
#  name                      :string
#  payment_model             :string
#  routing_number_ciphertext :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_id                  :bigint           not null
#
# Indexes
#
#  index_payment_recipients_on_event_id  (event_id)
#  index_payment_recipients_on_name      (name)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
class PaymentRecipient < ApplicationRecord
  has_paper_trail

  default_scope { order_by_last_used }

  belongs_to :event
  has_many :ach_transfers

  has_encrypted :account_number, :routing_number, :bank_name

  scope :order_by_last_used, -> { includes(:ach_transfers).order("ach_transfers.created_at DESC") }

  validates_email_format_of :email
  normalizes :email, with: ->(email) { email.strip.downcase }

  has_encrypted :information, type: :json
  store :information, accessors: [:account_number, :routing_number, :bank_name]

  def account_number
    information["account_number"] || PaymentRecipient.decrypt_account_number_ciphertext(account_number_ciphertext)
  end

  def routing_number
    information["routing_number"] || PaymentRecipient.decrypt_routing_number_ciphertext(routing_number_ciphertext)
  end

  def bank_name
    information["bank_name"] || PaymentRecipient.decrypt_bank_name_ciphertext(bank_name_ciphertext)
  end

  def masked_account_number
    return account_number if account_number.length <= 4

    account_number.slice(-4, 4).rjust(account_number.length, "•")
  end

  def to_safe_hash
    {
      id:,
      name:,
      email:,
      masked_account_number:,
      bank_name:,
      routing_number:,
    }
  end

  def to_safe_json
    to_safe_hash.to_json
  end

end
