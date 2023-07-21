# frozen_string_literal: true

# == Schema Information
#
# Table name: api_tokens
#
#  id               :bigint           not null, primary key
#  token_bidx       :string
#  token_ciphertext :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_api_tokens_on_token_bidx  (token_bidx) UNIQUE
#  index_api_tokens_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ApiToken < ApplicationRecord
  PREFIX = "hcb_"

  has_encrypted :token
  blind_index :token

  belongs_to :user

  before_create :generate_token

  private

  def generate_token
    self.token ||= PREFIX + SecureRandom.hex
  end

end
