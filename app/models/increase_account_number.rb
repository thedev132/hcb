# frozen_string_literal: true

# == Schema Information
#
# Table name: increase_account_numbers
#
#  id                         :bigint           not null, primary key
#  account_number_ciphertext  :text
#  routing_number_ciphertext  :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  event_id                   :bigint           not null
#  increase_account_number_id :string
#  increase_limit_id          :string
#
# Indexes
#
#  index_increase_account_numbers_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
class IncreaseAccountNumber < ApplicationRecord
  belongs_to :event

  has_encrypted :account_number, :routing_number

  before_create :create_increase_account_number

  validate do
    if event.demo_mode?
      errors.add(:base, "Can't create an account number for a Playground Mode org")
    end
  end

  private

  def create_increase_account_number
    increase_account_number = Increase::AccountNumbers.create(
      account_id: IncreaseService::AccountIds::FS_MAIN,
      name: "##{event.id} (#{event.name})"
    )

    self.increase_account_number_id = increase_account_number["id"]
    self.account_number = increase_account_number["account_number"]
    self.routing_number = increase_account_number["routing_number"]

    # Restrict debits to $1.00 per day
    increase_limit = Increase::Limits.create(
      interval: "day",
      metric: "volume",
      value: 100,
      model_id: increase_account_number["id"],
    )

    self.increase_limit_id = increase_limit["id"]
  end

end
