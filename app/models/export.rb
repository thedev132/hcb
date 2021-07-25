# frozen_string_literal: true

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
