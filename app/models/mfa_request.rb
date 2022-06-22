# frozen_string_literal: true

# == Schema Information
#
# Table name: mfa_requests
#
#  id          :bigint           not null, primary key
#  aasm_state  :string
#  provider    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  mfa_code_id :bigint
#
# Indexes
#
#  index_mfa_requests_on_mfa_code_id  (mfa_code_id)
#
# Foreign Keys
#
#  fk_rails_...  (mfa_code_id => mfa_codes.id)
#
class MfaRequest < ApplicationRecord
  include AASM

  belongs_to :mfa_code, optional: true

  aasm do
    state :pending, initial: true
    state :received

    event :mark_received do
      transitions from: :pending, to: :received
    end
  end

end
