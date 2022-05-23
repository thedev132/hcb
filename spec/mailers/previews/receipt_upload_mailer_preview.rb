# frozen_string_literal: true

class ReceiptUploadMailerPreview < ActionMailer::Preview
  def bounce_missing_user
    ReceiptUploadMailer.with(
      to: 'test@example.com'
    ).bounce_missing_user
  end

  def bounce_missing_hcb
    ReceiptUploadMailer.with(
      to: 'test@example.com'
    ).bounce_missing_hcb
  end

  def bounce_missing_attachment
    ReceiptUploadMailer.with(
      to: 'test@example.com'
    ).bounce_missing_attachment
  end

  def bounce_error
    ReceiptUploadMailer.with(
      to: 'test@example.com'
    ).bounce_error
  end

  def bounce_success
    ReceiptUploadMailer.with(
      to: 'test@example.com',
      receipts_count: 1
    ).bounce_success
  end

end
