# frozen_string_literal: true

# == Schema Information
#
# Table name: login_codes
#
#  id         :bigint           not null, primary key
#  code       :text
#  ip_address :inet
#  used_at    :datetime
#  user_agent :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_login_codes_on_code     (code) UNIQUE WHERE (used_at IS NULL)
#  index_login_codes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class LoginCode < ApplicationRecord
  scope :active, -> { where(used_at: nil) }

  belongs_to :user

  before_create :generate_code

  # "123456" -> "123-456"
  def pretty
    code&.scan(/.../)&.join("-")
  end

  def active?
    used_at.nil?
  end

  private

  def generate_code
    self.code = SecureRandom.random_number(999_999).to_s.ljust(6, "0") # pad with zero(s) if needed
  end

end
