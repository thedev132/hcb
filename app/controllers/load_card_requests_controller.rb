class LoadCardRequestsController < ApplicationController
  before_action :set_load_card_request, only: [:show, :edit, :update, :destroy]

  # GET /load_card_requests
  def index
    @load_card_requests = LoadCardRequest.all
  end

  # GET /load_card_requests/1
  def show
  end

  # GET /load_card_requests/new
  def new
    @load_card_request = LoadCardRequest.new
  end

  # GET /load_card_requests/1/edit
  def edit
  end

  # POST /load_card_requests
  def create
    @load_card_request = LoadCardRequest.new(load_card_request_params)

    if @load_card_request.save
      redirect_to @load_card_request, notice: 'Load card request was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /load_card_requests/1
  def update
    if @load_card_request.update(load_card_request_params)
      redirect_to @load_card_request, notice: 'Load card request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /load_card_requests/1
  def destroy
    @load_card_request.destroy
    redirect_to load_card_requests_url, notice: 'Load card request was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_card_request
      @load_card_request = LoadCardRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def load_card_request_params
      params.require(:load_card_request).permit(:card_id, :user_id, :fulfilled_by, :fulfilled_at, :load_amount)
    end
end
