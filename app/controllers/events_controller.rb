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
    fixed_event_params[:partner_logo_url] = nil if event_params.key?(:partner_logo_url) && event_params[:partner_logo_url].empty?

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
    @stripe_cardholders = StripeCardholder.where(user_id: @event.users.pluck(:id)).order("created_at desc")

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
      :partner_logo_url,
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
