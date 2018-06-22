class CardRequestsController < ApplicationController
  before_action :set_card_request, only: [:show, :edit, :update, :destroy]

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

  # POST /card_requests
  def create
    @card_request = CardRequest.new(card_request_params)

    if @card_request.save
      redirect_to @card_request, notice: 'Card request was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /card_requests/1
  def update
    if @card_request.update(card_request_params)
      redirect_to @card_request, notice: 'Card request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /card_requests/1
  def destroy
    @card_request.destroy
    redirect_to card_requests_url, notice: 'Card request was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_request
      @card_request = CardRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_request_params
      params.require(:card_request).permit(:user_id, :event_id, :daily_limit)
    end
end
