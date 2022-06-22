# frozen_string_literal: true

# == Schema Information
#
# Table name: exports
#
#  id         :bigint           not null, primary key
#  type       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_exports_on_type     (type)
#  index_exports_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class FinancialExport < Export
end
