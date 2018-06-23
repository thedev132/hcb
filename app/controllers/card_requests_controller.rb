class CardRequestsController < ApplicationController
  before_action :signed_in_user
  before_action :signed_in_admin, only: [:accept, :reject]
  before_action :set_card_request, only: [:show, :edit, :update, :destroy]
  before_action :ensure_pending_request, only: [:update, :edit]

  # GET /card_requests
  def index
    @card_requests = CardRequest.all
  end

  # GET /card_requests/1
  def show
  end

  # GET /card_requests/new
  def new
    @card_request = CardRequest.new
  end

  # GET /card_requests/1/edit
  def edit
  end

  def accept
    @card_request = CardRequest.find(params[:card_request_id])
    @card_request.accepted_at = Time.current
    @card_request.fulfilled_by = current_user
    @card = Card.create(
      daily_limit: @card_request.daily_limit,
      full_name: @card_request.full_name,
      card_request: @card_request
    )
  end

  def reject
    @card_request = CardRequest.find(params[:card_request_id])
    @card_request.rejected_at = Time.current
  end

  # POST /card_requests
  def create
    @card_request = CardRequest.new(card_request_params)
    @card_request.creator = current_user

    if @card_request.save
      flash[:success] = 'Your card request is being reviewed.'
      redirect_to @card_request
    else
      render :new
    end
  end

  # PATCH/PUT /card_requests/1
  def update
    if @card_request.update(card_request_params)
      flash[:success] = 'Changes to card request saved.'
      redirect_to @card_request
    else
      render :edit
    end
  end

  # DELETE /card_requests/1
  def destroy
    @card_request.canceled_at = Time.now
    redirect_to card_requests_url, notice: 'Request canceled'
  end

  private

    def ensure_pending_request
      raise 'Requests cannot be edited after they are accepted' if @card_request.accepted_at.present?
      raise 'Requests cannot be edited after they are rejected' if @card_request.rejected_at.present?
      raise 'Requests cannot be edited after they are canceled' if @card_request.canceled_at.present?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_card_request
      @card_request = CardRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_request_params
      params.require(:card_request).permit(:daily_limit, :shipping_address, :full_name, :rejected_at, :accepted_at, :notes, :event_id)
    end
end
