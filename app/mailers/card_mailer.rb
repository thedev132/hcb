class CardMailer < ApplicationMailer
  def emburse_migration
    @user = params[:user]
    @events_with_cards = @user.emburse_cards.map(&:event)
    @event_names = @event.pluck(:name).join(', ')
    @event_code = @events.pluck(:id)('|')
    @form_link = "https://hack.af/emburse_migration?Prefill_Account=#{@user.email}&Prefill_Events=#{@eventCode}-#{@event_names}"

    mail to: @user.email
         subject: "[Action Requested] Your Hack Club Bank card expires by Sept 15th"
  end
end