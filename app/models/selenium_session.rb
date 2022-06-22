# frozen_string_literal: true

# == Schema Information
#
# Table name: selenium_sessions
#
#  id         :bigint           not null, primary key
#  aasm_state :string
#  cookies    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SeleniumSession < ApplicationRecord
  include AASM

  aasm do
    state :active, initial: true
    state :expired

    event :mark_expired do
      transitions from: :active, to: :expired
    end
  end

end
