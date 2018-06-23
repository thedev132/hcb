class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_admin, only: [:edit, :update, :destroy]

  # GET /cards
  def index
    @cards = Card.all
  end

  # GET /cards/1
  def show
  end

  # GET /cards/new
  def new
    @card_request = CardRequest.find(params[:card_request_id])
    @card = Card.new(
      event: @card_request.event,
      user_id: @card_request.creator_id,
      daily_limit: @card_request.daily_limit,
      full_name: @card_request.full_name,
      address: @card_request.shipping_address,
      card_request_id: @card_request.id
    )
  end

  # GET /cards/1/edit
  # def edit
  # end

  # POST /cards
  def create
    @card_request = CardRequest.find(card_params['card_request_id'])
    @card = Card.new(card_params)
    @card_request.accepted_at = Time.current
    @card_request.fulfilled_by = current_user

    if @card.save && @card_request.save
      redirect_to @card, notice: 'Card was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /cards/1
  # def update
  #   if @card.update(card_params)
  #     redirect_to @card, notice: 'Card was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  # DELETE /cards/1
  # def destroy
  #   @card.destroy
  #   redirect_to cards_url, notice: 'Card was successfully destroyed.'
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_params
      params.require(:card).permit(:user_id, :event_id, :daily_limit, :full_name, :address, :card_request_id, :last_four, :expiration_month, :expiration_year, :emburse_id)
    end
end
