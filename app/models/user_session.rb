# frozen_string_literal: true

class UserSession < ApplicationRecord
  acts_as_paranoid
  belongs_to :user

end
