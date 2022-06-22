# frozen_string_literal: true

# == Schema Information
#
# Table name: mfa_codes
#
#  id         :bigint           not null, primary key
#  code       :string
#  message    :text
#  provider   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MfaCode < ApplicationRecord
  has_one :mfa_request, required: false

end
