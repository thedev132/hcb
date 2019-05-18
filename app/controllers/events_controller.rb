class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

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
    @event = Event.new(event_params)
    authorize @event

    if @event.save
      flash[:success] = 'Event was successfully created.'
      redirect_to @event
    else
      render :new
    end
  end

  # GET /events/1
  def show
    authorize @event
    @organizers = @event.organizer_positions.includes(:user)
    @transactions = @event.transactions.includes(:fee_relationship)
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

    if @event.update(current_user.admin? ? event_params : user_event_params)
      flash[:success] = 'Event was successfully updated.'
      redirect_to @event
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    authorize @event

    @event.destroy
    flash[:success] = 'Event was successfully destroyed.'
    redirect_to events_url
  end

  def card_overview
    @event = Event.find(params[:event_id])
    authorize @event
    @card_requests = @event.card_requests
    @load_card_requests = @event.load_card_requests
    @emburse_transactions = @event.emburse_transactions.order(transaction_time: :desc).where.not(transaction_time: nil).includes(:card)
  end

  def g_suite_overview
    @event = Event.find(params[:event_id])
    authorize @event
    @status = @event.g_suite_status
    @g_suite = @event.g_suite
    @g_suite_application = @event.g_suite_application
    @g_suite_status = @event.g_suite_status
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      flash[:error] = "We couldn't find that event!"
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
      :emburse_department_id,
      :point_of_contact_id,
      :slug
    )

    # Expected budget is in cents on the backend, but dollars on the frontend
    result_params[:expected_budget] = result_params[:expected_budget].to_f * 100

    result_params
  end

  def user_event_params
    params.require(:event).permit(
      :address,
      :slug
    )
  end
end
