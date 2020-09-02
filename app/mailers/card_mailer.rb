class CardMailer < ApplicationMailer
  def emburse_migration
    @user = params[:user]
    @events_with_cards = @user.emburse_cards.map(&:event).uniq
    @event_names = @events_with_cards.pluck(:name)
    @event_code = @events_with_cards.pluck(:id)
    @form_links = @events_with_cards.map do |event|
      {
        name: event.name,
        url: "https://hack.af/emburse_migration?prefill_Account=#{@user.email}|#{@user.id}&prefill_Events=#{event.id}-#{event.name}"
      }
    end

    mail to: @user.email,
         subject: "[Action Requested] Your Hack Club Bank card expires Sept 15th"
  end
end