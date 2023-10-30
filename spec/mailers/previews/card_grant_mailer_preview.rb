# frozen_string_literal: true

class CardGrantMailerPreview < ActionMailer::Preview
  def card_grant_notification
    CardGrantMailer.with(card_grant:).card_grant_notification
  end

  private

  def card_grant
    CardGrant.last
  end

end
