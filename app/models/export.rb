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

# Do not create instances of this class directly. You must create an instance
# of a child class, like FinancialExport. This class is meant to serve as the
# base class for different data exports we build.
class Export < ApplicationRecord
  belongs_to :user

  before_create :validate_child

  private

  def validate_child
    return if self.class != Export

    errors.add(:base, "Do not create intances of Export directly. Create instances of children instead.")
  end

end
