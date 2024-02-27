# frozen_string_literal: true

class HcbCodeMailerPreview < ActionMailer::Preview
  def bounce_missing_user
    HcbCodeMailer.with(
      to: "test@example.com"
    ).bounce_missing_user
  end

  def bounce_missing_hcb
    HcbCodeMailer.with(
      to: "test@example.com"
    ).bounce_missing_hcb
  end

  def bounce_missing_attachment
    HcbCodeMailer.with(
      to: "test@example.com"
    ).bounce_missing_attachment
  end

  def bounce_error
    HcbCodeMailer.with(
      to: "test@example.com"
    ).bounce_error
  end

  def bounce_success
    HcbCodeMailer.with(
      to: "test@example.com",
      receipts_count: 1
    ).bounce_success
  end

end
