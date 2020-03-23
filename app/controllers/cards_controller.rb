class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy, :toggle_active]

  # GET /cards
  def index
    @cards = Card.all.includes(:event, :user).page params[:page]
    authorize @cards
  end

  # GET /cards/1
  def show
    authorize @card
    @load_card_requests = @card.load_card_requests
    @emburse_transactions = @card.emburse_transactions.order(transaction_time: :desc)
  end

  # GET /cards/new
  def new
    @card_request = CardRequest.find(params[:card_request_id])
    @card = Card.new(
      event: @card_request.event,
      user_id: @card_request.creator_id,
      full_name: @card_request.full_name,
      address: @card_request.shipping_address_full,
      card_request: @card_request
    )
    authorize @card
  end

  # GET /cards/1/edit
  def edit
    authorize @card
  end

  # POST /cards
  def create
    @card_request = CardRequest.find(card_params['card_request_id'])
    @card = Card.new(
      user_id: card_params[:user_id],
      event_id: card_params[:event_id],
      emburse_id: card_params[:emburse_id],
      is_virtual: card_params[:is_virtual],
      last_four: card_params[:last_four],
      full_name: card_params[:full_name],
      address: card_params[:address],
      expiration_year: card_params[:expiration_year],
      expiration_month: card_params[:expiration_month]
    )

    authorize @card

    @card.card_request = @card_request
    @card_request.accepted_at = Time.current
    @card_request.fulfilled_by = current_user

    if @card.save && @card_request.save
      @card_request.send_accept_email
      flash[:success] = 'Card was successfully created.'
      redirect_to @card
    else
      render :new
    end
  end

  # PATCH/PUT /cards/1
  def update
    authorize @card

    if @card.update(card_params)
      flash[:success] = 'Card was successfully updated.'
      redirect_to @card
    else
      render :edit
    end
  end

  # DELETE /cards/1
  def destroy
    authorize @card

    @card.deleted_at = Time.now
    flash[:success] = 'Card was successfully destroyed.'
    redirect_to cards_url
  end

  def toggle_active
    authorize @card

    if @card.requires_activation?
      flash[:error] = 'Card must be activated first!'
      return redirect_to @card
    end

    if @card.active?
      @card.deactivate!
      flash[:success] = 'Card deactivated.'
    elsif
      @card.reactivate!
      flash[:success] = 'Card reactivated.'
    end

    redirect_to @card
  end

  def status
    @event = Event.find(params[:event_id])
    @card_requests = @event.card_requests.under_review
    @load_card_requests = @event.load_card_requests
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_card
    @card = Card.find(params[:id] || params[:card_id])
    @event = @card.event
  end

  # Only allow a trusted parameter "white list" through.
  def card_params
    params.require(:card).permit(
      :user_id,
      :event_id,
      :full_name,
      :address,
      :card_request_id,
      :is_virtual,
      :last_four,
      :expiration_month,
      :expiration_year,
      :emburse_id,
    )
  end
end
