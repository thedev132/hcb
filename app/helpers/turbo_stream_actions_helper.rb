# frozen_string_literal: true

module TurboStreamActionsHelper
  def refresh_link_modals
    turbo_stream_action_tag :refresh_link_modals
  end
end

Turbo::Streams::TagBuilder.prepend(TurboStreamActionsHelper)
