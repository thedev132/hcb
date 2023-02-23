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

  validates :user, :code, presence: true

  after_initialize :generate_code

  # "123456" -> "123-456"
  def pretty
    code&.scan(/.../)&.join('-')
  end

  def active?
    used_at.nil?
  end

  private

  # i don't know how to test to make sure this won't generate duplicate active
  # codes. here's a breakdown of the logic here:
  #
  # 1. generate a code
  # 2. check to make sure the code isn't used by any active login codes
  # 3. regenerate if used, keep if not
  def generate_code
    return if persisted?

    loop do
      self.code = SecureRandom.random_number(999_999).to_s
      self.code = code.ljust(6, '0') # left pad w/ zero

      break unless LoginCode.active.find_by(code: code)
    end
  end

end
