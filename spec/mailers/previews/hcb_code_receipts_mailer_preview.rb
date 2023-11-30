# frozen_string_literal: true

class HcbCodeReceiptsMailerPreview < ActionMailer::Preview
  def bounce_missing_user
    HcbCodeReceiptsMailer.with(
      to: "test@example.com"
    ).bounce_missing_user
  end

  def bounce_missing_hcb
    HcbCodeReceiptsMailer.with(
      to: "test@example.com"
    ).bounce_missing_hcb
  end

  def bounce_missing_attachment
    HcbCodeReceiptsMailer.with(
      to: "test@example.com"
    ).bounce_missing_attachment
  end

  def bounce_error
    HcbCodeReceiptsMailer.with(
      to: "test@example.com"
    ).bounce_error
  end

  def bounce_success
    HcbCodeReceiptsMailer.with(
      to: "test@example.com",
      receipts_count: 1
    ).bounce_success
  end

end
