# frozen_string_literal: true

class OperationsMailerPreview < ActionMailer::Preview
  def g_suite_entering_created_state
    @g_suite_id = GSuite.last.id
    OperationsMailer.with(g_suite_id: @g_suite_id).g_suite_entering_created_state
  end

  def g_suite_entering_verifying_state
    @g_suite_id = GSuite.last.id
    OperationsMailer.with(g_suite_id: @g_suite_id).g_suite_entering_verifying_state
  end

  def demo_mode_request_meeting
    @event_id = Event.filter_demo_mode(true).last.id
    OperationsMailer.with(event_id: @event_id).demo_mode_request_meeting
  end

end
