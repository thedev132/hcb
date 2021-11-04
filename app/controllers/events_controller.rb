# frozen_string_literal: true

class EventsController < ApplicationController
  include Rails::Pagination
  before_action :set_event, except: [:index, :new, :create, :by_airtable_id]
  skip_before_action :signed_in_user

  # GET /events
  def index
    authorize Event

    @event_ids_with_transactions_cache = FeeRelationship.distinct.pluck(:event_id) # for performance reasons - until we build proper counter caching and modify schemas a bit for easier calculations
    @events = Event.all
  end

  # GET /events/1
  def show
    authorize @event
    @organizers = @event.organizer_positions.includes(:user)
    @pending_transactions = _show_pending_transactions

    if using_transaction_engine_v2?
      @transactions_flat = [] #paginate(_show_transactions, per_page: 100) # v2. placeholder for flat history.
      @transactions = Kaminari.paginate_array(TransactionGroupingEngine::Transaction::All.new(event_id: @event.id, search: params[:search]).run).page(params[:page]).per(100)
    else
      @transactions = paginate(TransactionEngine::Transaction::AllDeprecated.new(event_id: @event.id).run, per_page: 100)
    end
  end

  def fees
    authorize @event

    @fees = @event.fees.includes(canonical_event_mapping: :canonical_transaction).order("canonical_transactions.date desc, canonical_transactions.id desc")
  end

  # async frame for incoming money
  def dashboard_stats
    authorize @event

    render :dashboard_stats, layout: false
  end

  # GET /event_by_airtable_id/recABC
  def by_airtable_id
    authorize Event
    @event = Event.find_by(club_airtable_id: params[:airtable_id])

    if @event.nil?
      flash[:error] = "We couldn’t find that event!"
      redirect_to root_path
    else
      redirect_to @event
    end
  end

  def team
    authorize @event
    @positions = @event.organizer_positions.includes(:user)
    @pending = @event.organizer_position_invites.pending.includes(:sender)
  end

  # GET /events/1/edit
  def edit
    authorize @event
  end

  # PATCH/PUT /events/1
  def update
    authorize @event

    # have to use `fixed_event_params` because `event_params` seems to be a constant
    fixed_event_params = event_params
    fixed_user_event_params = user_event_params

    fixed_event_params[:club_airtable_id] = nil if event_params.key?(:club_airtable_id) && event_params[:club_airtable_id].empty?

    # processing hidden for admins
    if fixed_event_params[:hidden] == "1" && !@event.hidden_at.present?
      fixed_event_params[:hidden_at] = DateTime.now
    elsif fixed_event_params[:hidden] == "0" && @event.hidden_at.present?
      fixed_event_params[:hidden_at] = nil
    end
    fixed_event_params.delete(:hidden)

    # processing hidden for users
    if fixed_user_event_params[:hidden] == "1" && !@event.hidden_at.present?
      fixed_user_event_params[:hidden_at] = DateTime.now
    elsif fixed_user_event_params[:hidden] == "0" && @event.hidden_at.present?
      fixed_user_event_params[:hidden_at] = nil
    end
    fixed_user_event_params.delete(:hidden)

    if @event.update(current_user.admin? ? fixed_event_params : fixed_user_event_params)
      flash[:success] = "Project successfully updated."
      redirect_to edit_event_path(@event.slug)
    else
      render "edit"
    end
  end

  # DELETE /events/1
  def destroy
    authorize @event

    @event.destroy
    flash[:success] = "Project successfully destroyed."
    redirect_to events_url
  end

  def emburse_card_overview
    @event = Event.includes([
      { emburse_cards: :user },
      { emburse_transfers: [:t_transaction, :creator] }
    ]).find(params[:event_id])
    authorize @event
    @emburse_cards = @event.emburse_cards.includes(user: [:profile_picture_attachment])
    @emburse_card_requests = @event.emburse_card_requests.includes(creator: :profile_picture_attachment)
    @emburse_transfers = @event.emburse_transfers
    @emburse_transactions = @event.emburse_transactions.order(transaction_time: :desc).where.not(transaction_time: nil).includes(:emburse_card)

    @sum = @event.emburse_balance
  end

  def card_overview
    @stripe_cards = @event.stripe_cards.includes(:stripe_cardholder, :user).order("created_at desc")
    @session_user_stripe_card = []

    unless current_user.nil?
      @session_user_stripe_cards = @stripe_cards.filter { |card| card.user.id.eql?(current_user.id) }
      @stripe_cards = @stripe_cards.filter { |card| !card.user.id.eql?(current_user.id) }
    end

    @stripe_cardholders = StripeCardholder.where(user_id: @event.users.pluck(:id)).includes(:user).order("created_at desc")

    authorize @event
  end

  def documentation
    @event_name = @event.name

    authorize @event
  end

  # (@msw) these pages are for the WIP resources page.
  def connect_gofundme
    @event_name = @event.name

    @document_title = "Connect a GoFundMe Campaign"
    @document_subtitle = "Start a fundraising campaign with GoFundMe and pay out to your account on Hack Club Bank!"
    @document_image = "https://cloud-jl944nr65-hack-club-bot.vercel.app/004e072bbe1.png"
    @document_content = "
A great way to get the name of your organization out there is to create a fundraising campaign through a platform such as GoFundMe. However these platforms typically require you to cash out your donations through a bank account or PayPal

What happens if you don’t have your own PayPal or bank account? How do you get the money into Hack Club Bank?

**Hack Club Bank supports fundraiser payouts to your organization’s fund on Bank!** Simply get in touch with the Bank team to get set up with the information you’ll need. Once your donations are ready to be cashed out, a member of the Bank team will move those funds directly to your account. You will be responsible for monitoring your fundraising campaign and keeping track of your payouts. The Bank team will notify you of the total amount being moved and provide you with a summary of your donations.

- **Personal accounts.** If you have your own personal accounts and would prefer to use those rather than Hack Club’s, you may cash out those donations to the account of your choice; then, donate them directly to your organization on Hack Club Bank through your donation page or an invoice.
- **Payout to Hack Club Bank through PayPal.** To have your payouts sent directly to Hack Club Bank, your fundraising platform of choice must allow for payouts through PayPal. Due to security reasons, we are unable to share our account or routing numbers. Please keep in mind that PayPal will also charge a fee for your donations which will be cov _____.

### Get Started with GoFundMe (or your platform of choice)

1. Think of a catchy name for your campaign that fits with your organization’s objective for the fundraiser.
2. Create an account with the platform you will be using. You can select that you work for a charity as your nonprofit is fiscally sponsored by Hack Club Bank. (Just enter in our EIN or tax ID, `81-2908499`).
3. Then, reach out to the Bank team at bank@hackclub.com to let us know that you’re creating a fundraising campaign. We’ll help you get set up with payouts through Bank:
    1. Set up a quick 15-minute call. During this call, we'll set you up with our PayPal info, so you'll be able to receive donations right into Hack Club Bank!
    2. Next, you’ll need to send us an email; be sure to include the following information:
        1. **The name of your fundraising campaign** - the name of your nonprofit org will NOT automatically show up during payouts - we need the specific name that you are calling your fundraiser.
        2. **The duration of your campaign** - some are only set up for a month while others go on year round. Some also are only set up until they reach a goal - we need to know how long we’ll be mapping donations for you.
        3. **The frequency of payout for your campaign** - This will vary depending on the platform you are using.
        4. **Preferred email(s) for receiving notifications** - We will always fill you in on when we are moving money.
4. You are all set! The Bank team will move funds into your account as they are paid out and will notify you via email when they arrive.
    "

    authorize @event
  end

  # (@msw) these pages are for the WIP resources page.
  def receive_check
    @event_name = @event.name

    @document_title = "Receive Checks"
    @document_subtitle = "Deposit checks into your Hack Club Bank account"
    @document_image = "https://cloud-9sk4no7es-hack-club-bot.vercel.app/0slaps-jpg-this-image-can-hold-so-many-pixels.avi.onion.gif.7zip.msw.jpg"
    @document_content = "
Hack Club Bank supports physical check donations! However please keep in mind that checks are a slower form of payment and may take up to 3 weeks to arrive. This is due to the nature of the postal system and is unfortunately out of our control.

In order for your organization to recieve a check and have it deposited into your account on Hack Club Bank, your donor needs to make the check out to either \"Hack Club\" or \"The Hack Foundation.\" This is imperative as anything else in the \"Pay to the Order of\" field will cause the check to be reject by our bank, causing a significant delay in receiving the money. Below is an example of a properly filled out check:

![](https://cloud-82tb02emf-hack-club-bot.vercel.app/0img_0601.jpg)

Your organization name should also be included in the memo. This will help the Bank team correctly map the check as it arrives.

Once you know you’re donor is paying by check, please follow these steps:

1. **Notify your donor.** Have them make the check out to \“The Hack Foundation\" or \"Hack Club\” with your organization in the memo section of the check.
2. **Mail the check.** Make sure your donor mails the check to our mailing address. This is also super important. If the check is sent any where else, there will be a significant delay in recieving your donation.

Exactly how our mailing address should be written:
> The Hack Foundation
> 8605 Santa Monica Blvd #86294
> West Hollywood, CA 90069

Notify the Bank team (bank@hackclub.com) letting us know the name of the donor, donation amount, and the name of your organization. This is a failsafe in case they forget to put your organization name in the memo. The memo section isn’t always filled out, and it allows us to easily map the donation to the corresponding organization.
    "

    authorize @event
  end

  # (@msw) these pages are for the WIP resources page.
  def sell_merch
    event_name = @event.name

    @document_title = "Sell Merchandise"
    @document_subtitle = "Start an online swag shop and pay out to Hack Club Bank"
    @document_image = "https://cloud-fodxc88eu-hack-club-bot.vercel.app/0placeholder.png"
    @document_content = "
Selling some neat merch online? Connect your shop to Hack Club Bank for easy
financial management!  Follow these steps to have your funds go to your HCB
account:

1. **Verify** that the online shop you’re using allows for PayPal as a payout option.
1. **Get familiar with payouts.** You need to know the frequency of payouts as well as any thresholds you need to hit in order to trigger a payout. (For example, Redbubble requires a minimum of $20 in your account before they'll pay out your balance. Should your balance be below the minimum, it'll be added to the payout for the following month.)
1. **Get in touch with the Bank team** (bank@hackclub.com). A member of the Bank team will set up a call with you to set up your pay outs and gather necessary information (i.e. email preference, payout frequency, and point of contact).

It will be your responsibility to notify the Bank team of the amount of money you’re receiving for each payout. For example, if your Redbubble payout this month is $35, you need to tell us so that we can keep an eye out for the incoming funds. Neither your name nor the name of your organization will be tied to the payout. If you are expecting money, you need to tell us otherwise we will not be able to move funds.

Note: PayPal does charge a fee for using their platform; this fee is not from Hack Club Bank. Upon deposit in your organization's account, the 7% Hack Club Bank fee will still apply.
"

    authorize @event
  end

  def g_suite_overview
    authorize @event

    @g_suite = @event.g_suites.not_deleted.first
  end

  def g_suite_create
    authorize @event

    attrs = {
      current_user: current_user,
      event_id: @event.id,
      domain: params[:domain]
    }
    GSuiteService::Create.new(attrs).run

    redirect_to event_g_suite_overview_path(event_id: @event.slug)
  rescue => e
    redirect_to event_g_suite_overview_path(event_id: @event.slug), flash: { error: e.message }
  end

  def g_suite_verify
    authorize @event

    GSuiteService::MarkVerifying.new(g_suite_id: @event.g_suites.not_deleted.first.id).run

    redirect_to event_g_suite_overview_path(event_id: @event.slug)
  end

  def donation_overview
    authorize @event

    relation = @event.donations.not_pending

    @stats = {
      deposited: relation.deposited.sum(:amount),
      in_transit: relation.in_transit.sum(:amount),
      refunded: relation.refunded.sum(:amount)
    }

    relation = relation.in_transit if params[:filter] == "in_transit"
    relation = relation.deposited if params[:filter] == "deposited"
    relation = relation.refunded if params[:filter] == "refunded"
    relation = relation.search_name(params[:search]) if params[:search].present?

    @donations = relation.order(created_at: :desc)
  end

  def partner_donation_overview
    authorize @event

    relation = @event.partner_donations.not_pending

    @stats = {
      deposited: relation.deposited.sum(:payout_amount_cents),
      in_transit: relation.in_transit.sum(:payout_amount_cents),
    }

    relation = relation.in_transit if params[:filter] == "in_transit"
    relation = relation.deposited if params[:filter] == "deposited"

    @partner_donations = relation.order(created_at: :desc)
  end

  def bank_fees
    authorize @event

    relation1 = @event.bank_fees

    relation1 = relation1.in_transit if params[:filter] == "in_transit"
    relation1 = relation1.settled if params[:filter] == "settled"

    @bank_fees = relation1.order("created_at desc")
  end

  def transfers
    authorize @event

    ach_relation = @event.ach_transfers
    checks_relation = @event.checks

    @stats = {
      deposited: ach_relation.deposited.sum(:amount) + checks_relation.deposited.sum(:amount),
      in_transit: ach_relation.in_transit.sum(:amount) + checks_relation.in_transit_or_in_transit_and_processed.sum(:amount),
      canceled: ach_relation.rejected.sum(:amount) + checks_relation.canceled.sum(:amount)
    }

    ach_relation = ach_relation.in_transit if params[:filter] == "in_transit"
    ach_relation = ach_relation.deposited if params[:filter] == "deposited"
    ach_relation =ach_relation.rejected if params[:filter] == "canceled"
    ach_relation = ach_relation.search_recipient(params[:search]) if params[:search].present?
    @ach_transfers = ach_relation

    checks_relation = checks_relation.in_transit_or_in_transit_and_processed if params[:filter] == "in_transit"
    checks_relation = checks_relation.deposited if params[:filter] == "deposited"
    checks_relation = checks_relation.canceled if params[:filter] == "canceled"
    checks_relation = checks_relation.search_recipient(params[:search]) if params[:search].present?
    @checks = checks_relation

    @transfers = (@checks + @ach_transfers).sort_by { |o| o.created_at }.reverse
  end

  def promotions
    authorize @event
  end

  def reimbursements
    authorize @event
  end

  def toggle_hidden
    authorize @event

    if @event.hidden?
      flash[:success] = "Event un-hidden"
      @event.update(hidden_at: nil)
    else
      @event.update(hidden_at: Time.now)
      file_redirects = [
        "https://cloud-b01qqxaux.vercel.app/barking_dog_turned_into_wood_meme.mp4",
        "https://cloud-b01qqxaux.vercel.app/dog_transforms_after_seeing_chair.mp4",
        "https://cloud-b01qqxaux.vercel.app/dog_turns_into_bread__but_it_s_in_hd.mp4",
        "https://cloud-b01qqxaux.vercel.app/run_now_meme.mp4",
        "https://cloud-3qup26j81.vercel.app/bonk_sound_effect.mp4",
        "https://cloud-is6jebpbb.vercel.app/disappearing_doge_meme.mp4"
      ].sample

      redirect_to file_redirects
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.friendly.find(params[:event_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "We couldn’t find that event!"
    redirect_to root_path
  end

  # Only allow a trusted parameter "white list" through.
  def event_params
    result_params = params.require(:event).permit(
      :name,
      :start,
      :end,
      :address,
      :sponsorship_fee,
      :expected_budget,
      :omit_stats,
      :emburse_department_id,
      :country,
      :club_airtable_id,
      :point_of_contact_id,
      :slug,
      :beta_features_enabled,
      :hidden,
      :donation_page_enabled,
      :donation_page_message,
      :is_public,
      :public_message
    )

    # Expected budget is in cents on the backend, but dollars on the frontend
    result_params[:expected_budget] = result_params[:expected_budget].to_f * 100
    # convert whatever the user inputted into something that is a legal slug
    result_params[:slug] = ActiveSupport::Inflector.parameterize(user_event_params[:slug])

    result_params
  end

  def user_event_params
    result_params = params.require(:event).permit(
      :address,
      :slug,
      :hidden,
      :donation_page_enabled,
      :donation_page_message,
      :is_public,
      :public_message
    )

    # convert whatever the user inputted into something that is a legal slug
    result_params[:slug] = ActiveSupport::Inflector.parameterize(result_params[:slug])

    result_params
  end

  def _show_pending_transactions
    return [] if params[:page] && params[:page] != "1"
    return [] unless using_transaction_engine_v2? && using_pending_transaction_engine?

    PendingTransactionEngine::PendingTransaction::All.new(event_id: @event.id, search: params[:search]).run
  end
end
