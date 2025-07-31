# == Schema Information
#
# Table name: wise_transfers
#
#  id                            :bigint           not null, primary key
#  aasm_state                    :string
#  account_number_bidx           :string
#  account_number_ciphertext     :string
#  address_city                  :string
#  address_line1                 :string
#  address_line2                 :string
#  address_postal_code           :string
#  address_state                 :string
#  amount_cents                  :integer
#  approved_at                   :datetime
#  bank_name                     :string
#  bic_code_bidx                 :string
#  bic_code_ciphertext           :string
#  currency                      :string
#  memo                          :string
#  payment_for                   :string
#  recipient_birthday_ciphertext :text
#  recipient_country             :integer
#  recipient_email               :string
#  recipient_information         :jsonb
#  recipient_name                :string
#  recipient_phone_number        :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  event_id                      :bigint           not null
#  user_id                       :bigint           not null
#  wise_id                       :text
#
# Indexes
#
#  index_wise_transfers_on_event_id  (event_id)
#  index_wise_transfers_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class WiseTransfer < ApplicationRecord
  belongs_to :event
  belongs_to :user
end
