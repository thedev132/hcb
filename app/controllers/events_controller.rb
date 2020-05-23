class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  skip_before_action :signed_in_user

  # GET /events
  def index
    authorize Event

    @events = Event.all.includes(:point_of_contact)
  end

  # GET /events/new
  def new
    @event = Event.new
    authorize @event
  end

  # POST /events
  def create
    # have to use `fixed_event_params` because `event_params` seems to be a constant
    fixed_event_params = event_params

    fixed_event_params[:club_airtable_id] = nil if event_params.key?(:club_airtable_id) && event_params[:club_airtable_id].empty?
    fixed_event_params[:partner_logo_url] = nil if event_params.key?(:partner_logo_url) && event_params[:partner_logo_url].empty?

    # all new events should be un-hidden, so no need to worry about setting it here
    # just delete the auxiliary param.
    fixed_event_params.delete(:hidden)

    @event = Event.new(fixed_event_params)
    authorize @event

    if @event.save
      flash[:success] = 'Event successfully created.'
      redirect_to @event
    else
      render :new
    end
  end

  # GET /events/1
  def show
    authorize @event
    @organizers = @event.organizer_positions.includes(:user)
    @transactions = @event.transactions.includes(:fee_relationship, :comments)

    @invoices_being_deposited = (@event.invoices.where(payout_id: nil, status: 'paid')
      .where
      .not(payout_creation_queued_for: nil) +
      @event.invoices.joins(:payout)
      .where(invoice_payouts: { status: ('in_transit') })
      .or(@event.invoices.joins(:payout).where(invoice_payouts: { status: ('pending') }))).sort_by { |i| i.arrival_date }

    @donations_being_deposited = (@event.donations.where(payout_id: nil, status: 'succeeded')
      .where
      .not(payout_creation_queued_for: nil) +
      @event.donations.joins(:payout)
      .where(donation_payouts: { status: ('in_transit') })
      .or(@event.donations.joins(:payout).where(donation_payouts: { status: ('pending') }))).sort_by { |d| d.arrival_date }
  end

  # GET /event_by_airtable_id/recABC
  def by_airtable_id
    authorize Event
    @event = Event.find_by(club_airtable_id: params[:airtable_id])

    if @event.nil?
      flash[:error] = 'We couldn’t find that event!'
      redirect_to root_path
    else
      redirect_to @event
    end
  end

  def team
    @event = Event.find(params[:event_id])
    @positions = @event.organizer_positions.includes(:user)
    @pending = @event.organizer_position_invites.pending.includes(:sender)
    authorize @event
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
      flash[:success] = 'Event successfully updated.'
      redirect_to edit_event_path(@event.slug)
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    authorize @event

    @event.destroy
    flash[:success] = 'Event successfully destroyed.'
    redirect_to events_url
  end

  def card_overview
    @event = Event.includes([
      { cards: :user },
      { load_card_requests: [:t_transaction, :creator] }
      ]).find(params[:event_id])
    authorize @event
    @cards = @event.cards.includes(user: [:profile_picture_attachment])
    @card_requests = @event.card_requests.includes(creator: :profile_picture_attachment)
    @load_card_requests = @event.load_card_requests
    @emburse_transactions = @event.emburse_transactions.order(transaction_time: :desc).where.not(transaction_time: nil).includes(:card)

    @sum = @event.emburse_balance
  end

  def g_suite_overview
    @event = Event.find(params[:event_id])
    authorize @event
    @status = @event.g_suite_status
    @g_suite = @event.g_suite
    @g_suite_application = @event.g_suite_application
    @g_suite_status = @event.g_suite_status
  end

  def donation_overview
    @event = Event.find(params[:event_id])
    authorize @event
    @donations = @event.donations.where(status: 'succeeded').sort_by {|d| d.created_at }.reverse
  end

  def transfers
    @event = Event.find(params[:event_id])
    authorize @event

    @checks = @event.checks.includes(:creator)
    @ach_transfers = @event.ach_transfers.includes(:creator)

    @transfers = (@checks + @ach_transfers).sort_by { |o| o.created_at }.reverse
  end

  def promotions
    @event = Event.find(params[:event_id])
    authorize @event
  end

  def reimbursements
    @event = Event.find(params[:event_id])
    authorize @event
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'We couldn’t find that event!'
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
      :has_fiscal_sponsorship_document,
      :emburse_department_id,
      :partner_logo_url,
      :club_airtable_id,
      :point_of_contact_id,
      :slug,
      :beta_features_enabled,
      :hidden,
      :is_spend_only,
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
end
