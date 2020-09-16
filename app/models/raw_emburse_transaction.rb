class RawEmburseTransaction < ApplicationRecord
  monetize :amount_cents
end
