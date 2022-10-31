# frozen_string_literal: true

# == Schema Information
#
# Table name: canonical_event_mappings
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  canonical_transaction_id :bigint           not null
#  event_id                 :bigint           not null
#  user_id                  :bigint
#
# Indexes
#
#  index_canonical_event_mappings_on_canonical_transaction_id  (canonical_transaction_id)
#  index_canonical_event_mappings_on_event_id                  (event_id)
#  index_canonical_event_mappings_on_user_id                   (user_id)
#  index_cem_event_id_canonical_transaction_id_uniqueness      (event_id,canonical_transaction_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (canonical_transaction_id => canonical_transactions.id)
#  fk_rails_...  (event_id => events.id)
#
class CanonicalEventMapping < ApplicationRecord
  belongs_to :canonical_transaction
  belongs_to :event
  belongs_to :user, optional: true

  has_many :fees

  after_create do
    FeeEngine::Create.new(canonical_event_mapping: self).run
  end

  scope :missing_fee, -> { includes(:fees).where(fees: { canonical_event_mapping_id: nil }) }
  scope :mapped_by_human, -> { where("user_id is not null") }

end
