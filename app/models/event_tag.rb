# frozen_string_literal: true

# == Schema Information
#
# Table name: event_tags
#
#  id          :bigint           not null, primary key
#  description :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_event_tags_on_name  (name) UNIQUE
#
class EventTag < ApplicationRecord
  include ActionView::Helpers::TextHelper # for `pluralize`

  has_and_belongs_to_many :events

  validates :name, presence: true, uniqueness: true

  def removal_confirmation_message
    message = "Are you sure you'd like to delete this tag?"
    return message if events.none?

    message + " It will be removed from #{pluralize(events.size, 'organization')}."
  end

end

class EventTag
  module Tags
    ORGANIZED_BY_HACK_CLUBBERS = "Organized by Hack Clubbers"
    ORGANIZED_BY_TEENAGERS = "Organized by Teenagers"
  end

end
