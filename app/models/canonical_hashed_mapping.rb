# frozen_string_literal: true

# == Schema Information
#
# Table name: canonical_hashed_mappings
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  canonical_transaction_id :bigint           not null
#  hashed_transaction_id    :bigint           not null
#
# Indexes
#
#  index_canonical_hashed_mappings_on_canonical_transaction_id  (canonical_transaction_id)
#  index_canonical_hashed_mappings_on_hashed_transaction_id     (hashed_transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (canonical_transaction_id => canonical_transactions.id)
#  fk_rails_...  (hashed_transaction_id => hashed_transactions.id)
#
class CanonicalHashedMapping < ApplicationRecord
  belongs_to :canonical_transaction
  belongs_to :hashed_transaction

end
