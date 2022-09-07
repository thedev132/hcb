# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  color      :text
#  label      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#
# Indexes
#
#  index_tags_on_event_id  (event_id)
#
class Tag < ApplicationRecord
  include ActionView::Helpers::TextHelper # for `pluralize`

  include PublicIdentifiable
  set_public_id_prefix :tag

  belongs_to :event
  has_and_belongs_to_many :hcb_codes

  validates :label, presence: true, uniqueness: { scope: :event_id, case_sensitive: false }
  validates_format_of :color, with: /\A#(?:\h{3}){1,2}\z/, allow_nil: true, message: 'must be a color hex code'

  def removal_confirmation_message
    message = "Are you sure you'd like to delete this tag?"

    if hcb_codes.length > 0
      message + " It will be removed from #{pluralize(hcb_codes.length, 'transaction')}."
    else
      message
    end
  end

end
