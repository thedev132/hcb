# frozen_string_literal: true

class OperationsMailer < ApplicationMailer
  def g_suite_entering_created_state
    @g_suite = GSuite.find(params[:g_suite_id])

    attrs = {
      to: ::ApplicationMailer::OPERATIONS_EMAIL,
      subject: "[OPS] [ACTION] [GSuite] Configure #{@g_suite.domain}"
    }

    mail attrs
  end

  def g_suite_entering_verifying_state
    @g_suite = GSuite.find(params[:g_suite_id])

    attrs = {
      to: ::ApplicationMailer::OPERATIONS_EMAIL,
      subject: "[OPS] [ACTION] [GSuite] Verify #{@g_suite.domain}"
    }

    mail attrs
  end
end
