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

end
