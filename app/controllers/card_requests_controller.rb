class CardRequestsController < ApplicationController
  before_action :signed_in_user
  before_action :set_card_request, only: [:show, :edit, :update, :destroy]
  before_action :ensure_pending_request, only: [:update, :edit]

  # GET /card_requests
  def index
    @card_requests = CardRequest.all
    authorize @card_requests
  end

  # GET /card_requests/1
  def show
    authorize @card_request
  end

  # GET /card_requests/new
  def new
    @event = Event.find(params[:event_id]) if params[:event_id]
    @card_request = CardRequest.new(event: @event)

    authorize @card_request
  end

  # GET /card_requests/1/edit
  def edit
    authorize @card_request
  end

  def reject
    @card_request = CardRequest.find(params[:card_request_id])

    authorize @card_request

    @card_request.rejected_at = Time.current
    if @card_request.save
      flash[:success] = 'Card request rejected.'
      redirect_to card_requests_path
    end
  end

  # POST /card_requests
  def create
    @card_request = CardRequest.new(card_request_params)
    @card_request.daily_limit = card_request_params['daily_limit'].to_i * 100
    @card_request.creator = current_user
    @event = @card_request.event

    authorize @card_request

    if @card_request.save
      flash[:success] = 'Your card request is being reviewed.'
      redirect_to @event
    else
      render :new
    end
  end

  # PATCH/PUT /card_requests/1
  def update
    authorize @card_request
    if @card_request.update(card_request_params)
      flash[:success] = 'Changes to card request saved.'
      redirect_to @card_request
    else
      render :edit
    end
  end

  # POST /card_requests/1
  def cancel
    authorize @card_request
    @card_request.canceled_at = Time.now
    if @card_request.save
      flash[:success] = 'Canceled your card request.'
      redirect_to @event
    else
      redirect_to @event
    end
  end

  private

    def ensure_pending_request
      raise 'Requests cannot be edited after they are accepted' if @card_request.accepted_at.present?
      raise 'Requests cannot be edited after they are rejected' if @card_request.rejected_at.present?
      raise 'Requests cannot be edited after they are canceled' if @card_request.canceled_at.present?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_card_request
      @card_request = CardRequest.find(params[:id] || params[:card_request_id])
      @event = @card_request.event
    end

    # Only allow a trusted parameter "white list" through.
    def card_request_params
      params.require(:card_request).permit(:daily_limit, :shipping_address, :full_name, :rejected_at, :accepted_at, :notes, :event_id)
    end
end
