class LoadCardRequestsController < ApplicationController
  before_action :set_load_card_request, only: [:show, :edit, :update, :reject, :cancel, :accept]

  def index
    @load_card_requests = LoadCardRequest.all.order(created_at: :desc)
    authorize @load_card_requests
  end

  def show
    @event = @load_card_request.event
    authorize @load_card_request
  end

  def new
    @event = Event.find(params[:event_id])
    @load_card_request = LoadCardRequest.new(event: @event)

    authorize @load_card_request
  end

  def edit
    authorize @load_card_request
  end

  def create
    @load_card_request = LoadCardRequest.new(load_card_request_params)
    @event = Event.find(params[:event_id])

    authorize @load_card_request

    if @load_card_request.save
      redirect_to @event, notice: 'Load card request was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @load_card_request

    if @load_card_request.update(load_card_request_params)
      flash[:success] = 'Load card request was successfully updated.'
      redirect_to @load_card_request.event
    else
      render :edit
    end
  end

  def accept
    @load_card_request.accepted_at = Time.now
    @load_card_request.fulfilled_by = current_user

    authorize @load_card_request

    if @load_card_request.save
      flash[:success] = 'Load card request accepted.'
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to edit_event_load_card_request_path(@load_card_request, event_id: @load_card_request.event.id)
  end

  def reject
    authorize @load_card_request

    @load_card_request.rejected_at = Time.now
    if @load_card_request.save
      flash[:success] = 'Load card request rejected.'
      redirect_to @load_card_request.event
    else
      redirect_to @load_card_request
    end
  end

  def cancel
    authorize @load_card_request

    @load_card_request.canceled_at = Time.now
    if @load_card_request.save
      flash[:success] = 'Load card request cancelled.'
      redirect_to @load_card_request.event
    else
      redirect_to @load_card_request
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_card_request
      @load_card_request = LoadCardRequest.find(params[:id] || params[:load_card_request_id])
    end

    # Only allow a trusted parameter "white list" through.
    def load_card_request_params
      params.require(:load_card_request).permit(:event_id, :creator_id, :load_amount, :emburse_transaction_id)
    end
end
