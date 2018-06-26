class LoadCardRequestsController < ApplicationController
  before_action :set_load_card_request, only: [:show, :edit, :update, :destroy]

  def index
    @load_card_requests = LoadCardRequest.all
    authorize @load_card_requests
  end

  def show
    @card = @load_card_request.card
    authorize @load_card_requests
  end

  def accept
    @load_card_request.fulfiled_at = Time.now
    @load_card_request.fulfiled_by = current_user

    authorize @load_card_requests

    @load_card_request.save
  end

  def new
    @card = Card.includes(:event).find(params[:card_id])
    @load_card_request = LoadCardRequest.new

    authorize @load_card_request
  end

  def edit
    authorize @load_card_requests
  end

  def create
    @load_card_request = LoadCardRequest.new(load_card_request_params)

    authorize @load_card_requests

    if @load_card_request.save
      redirect_to @load_card_request, notice: 'Load card request was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @load_card_requests

    if @load_card_request.update(load_card_request_params)
      flash[:success] = 'Load card request was successfully updated.'
      redirect_to load_card_requests
    else
      render :edit
    end
  end

  def destroy
    authorize @load_card_request

    @load_card_request.cancelled_at = Time.now
    flash[:success] = 'Load card request cancelled.'
    redirect_to @load_card_request.event
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_card_request
      @load_card_request = LoadCardRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def load_card_request_params
      params.require(:load_card_request).permit(:card_id, :creator_id, :load_amount)
    end
end
