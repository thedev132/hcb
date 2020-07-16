class EmburseCardsController < ApplicationController
  before_action :set_emburse_card, only: [:show, :edit, :update, :destroy, :toggle_active]
  skip_before_action :signed_in_user

  # GET /emburse_cards
  def index
    @emburse_cards = EmburseCard.all.includes(:event, :user).page params[:page]
    authorize @emburse_cards
  end

  # GET /emburse_cards/1
  def show
    authorize @emburse_card
    @emburse_transfers = @emburse_card.emburse_transfers
    @emburse_transactions = @emburse_card.emburse_transactions.order(transaction_time: :desc)
  end

  # GET /emburse_cards/new
  def new
    @emburse_card_request = EmburseCardRequest.find(params[:emburse_card_request_id])
    @emburse_card = EmburseCard.new(
      event: @emburse_card_request.event,
      user_id: @emburse_card_request.creator_id,
      full_name: @emburse_card_request.full_name,
      address: @emburse_card_request.shipping_address_full,
      emburse_card_request: @emburse_card_request
    )
    authorize @emburse_card
  end

  # GET /emburse_cards/1/edit
  def edit
    authorize @emburse_card
  end

  # POST /emburse_cards
  def create
    @emburse_card_request = EmburseCardRequest.find(emburse_card_params['emburse_card_request_id'])
    @emburse_card = EmburseCard.new(
      user_id: emburse_card_params[:user_id],
      event_id: emburse_card_params[:event_id],
      emburse_id: emburse_card_params[:emburse_id],
    )

    authorize @emburse_card

    @emburse_card.emburse_card_request = @emburse_card_request
    @emburse_card_request.accepted_at = Time.current
    @emburse_card_request.fulfilled_by = current_user

    if @emburse_card.save && @emburse_card_request.save
      @emburse_card_request.send_accept_email
      flash[:success] = 'Card was successfully created.'
      redirect_to @emburse_card
    else
      render :new
    end
  end

  # PATCH/PUT /emburse_cards/1
  def update
    authorize @emburse_card

    if @emburse_card.update(emburse_card_params)
      flash[:success] = 'Card was successfully updated.'
      redirect_to @emburse_card
    else
      render :edit
    end
  end

  # DELETE /emburse_cards/1
  def destroy
    authorize @emburse_card

    @emburse_card.deleted_at = Time.now
    flash[:success] = 'Card was successfully destroyed.'
    redirect_to emburse_cards_url
  end

  def toggle_active
    authorize @emburse_card

    if @emburse_card.requires_activation?
      flash[:error] = 'Card must be activated first!'
      return redirect_to @emburse_card
    end

    if @emburse_card.active?
      @emburse_card.deactivate!
      flash[:success] = 'Card deactivated.'
    elsif @emburse_card.reactivate!
      flash[:success] = 'Card reactivated.'
    end

    redirect_to @emburse_card
  end

  def status
    @event = Event.friendly.find(params[:event_id])
    @emburse_card_requests = @event.emburse_card_requests.under_review
    @emburse_transfers = @event.emburse_transfers
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_emburse_card
    @emburse_card = EmburseCard.friendly.find(params[:id] || params[:emburse_card_id])
    @event = @emburse_card.event
  end

  # Only allow a trusted parameter "white list" through.
  def emburse_card_params
    params.require(:emburse_card).permit(
      :user_id,
      :event_id,
      :emburse_card_request_id,
      :emburse_id,
    )
  end
end
