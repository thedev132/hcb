class EmburseCardMailer < ApplicationMailer
  def warn_of_migration
    @user = params[:user]
    @cards = @user.emburse_cards
    @events = @user.events

    @cards_with_subscriptions = @cards.select{|c| c.suspected_subscriptions.any?}

    @events_with_emburse_budget = @events.select{|e|e.emburse_balance > 0}
    @inactive_event = true #@user.events.where(emburse_transaction)
    @has_transactions = @cards.map(&:emburse_transactions).flatten.any?
    @has_subscriptions = @cards_with_subscriptions.any?

    mail to: @user.email,
         subject: "[Notice] Emburse cards are suspending in the next 2 weeks"
  end

  def card_cancelled
  end
end
