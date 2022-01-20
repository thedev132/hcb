# frozen_string_literal: true

class UserSession < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  belongs_to :impersonated_by, class_name: "User", required: false

  scope :impersonated, -> { where.not(impersonated_by_id: nil) }
  scope :not_impersonated, -> { where(impersonated_by_id: nil) }

  def impersonated?
    !impersonated_by.nil?
  end

end
