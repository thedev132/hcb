# frozen_string_literal: true

class ReimbursementMailer < ApplicationMailer
  def invitation
    @report = params[:report]

    mail to: @report.user.email, subject: "Get reimbursed by #{@report.event.name} for #{@report.name}", from: hcb_email_with_name_of(@report.event)
  end

  def reimbursement_approved
    @report = params[:report]

    mail to: @report.user.email, subject: "[Reimbursements] Approved: #{@report.name}", from: hcb_email_with_name_of(@report.event)
  end

  def rejected
    @report = params[:report]

    mail to: @report.user.email, subject: "[Reimbursements] Rejected: #{@report.name}", from: hcb_email_with_name_of(@report.event)
  end

  def review_requested
    @report = params[:report]

    mail to: @report.event.users.pluck(:email).excluding(@report.user.email), subject: "[Reimbursements] Review Requested: #{@report.name}"
  end

  def expense_approved
    @report = params[:report]
    @expense = params[:expense]

    mail to: @report.user.email, subject: "An update on your reimbursement for #{@expense.memo}", from: hcb_email_with_name_of(@report.event)
  end

  def expense_unapproved
    @report = params[:report]
    @expense = params[:expense]

    mail to: @report.user.email, subject: "An update on your reimbursement for #{@expense.memo}", from: hcb_email_with_name_of(@report.event)
  end

end
