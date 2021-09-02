class MfaCode < ApplicationRecord
  has_one :mfa_request, required: false

end
