class CardMailer < ApplicationMailer
  def emburse_migration
    @user = params[:user]
    @events_with_cards = @user.emburse_cards.where('is_virtual IS NOT TRUE').map(&:event).uniq
    address = EmburseCardRequest.where(creator_id: @user.id).where('fulfilled_by_id IS NOT NULL').where('is_virtual IS NOT TRUE').last
    @event_names = @events_with_cards.pluck(:name)
    @event_code = @events_with_cards.pluck(:id)
    @form_links = @events_with_cards.map do |event|
      prefills = {}
      prefills['prefill_Account'] = "#{@user.email}|#{@user.id}"
      prefills['prefill_Events'] = "#{event.id}-#{event.name}"
      if address.shipping_address
        prefills['prefill_Address'] = address.shipping_address
      else
        prefills['prefill_Line1'] = address.shipping_address_street_one
        prefills['prefill_Line2'] = address.shipping_address_street_two
        prefills['prefill_City'] = address.shipping_address_city
        prefills['prefill_State'] = address.shipping_address_state
        prefills['prefill_Postal'] = address.shipping_address_zip
      end

      {
        name: event.name,
        url: "https://hack.af/#{address.shipping_address ? 'emburse-migration-address' : 'emburse-migration' }?#{prefills.to_query}"
      }
    end

    mail to: @user.email,
         subject: "[Action Requested] Your Hack Club Bank card expires Sept 15th"
  end
end