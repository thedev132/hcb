class LoadCardRequestsController < ApplicationController
  before_action :set_load_card_request, only: [:show, :edit, :update, :reject, :cancel, :accept]
  skip_before_action :signed_in_user

  def export
    authorize LoadCardRequest

    lcrs = LoadCardRequest.under_review

    attributes = %w{load_amount emburse_memo}

    result = CSV.generate(headers: true) do |csv|
      csv << attributes.map

      lcrs.each do |lcr|
        csv << attributes.map do |attr|
          if attr == 'load_amount'
            lcr.load_amount.to_f / 100
          elsif attr == 'emburse_memo'
            "Transfer request ID##{lcr.id}"
          else
            cr.send(attr)
          end
        end
      end
    end

    send_data result, filename: "Pending LCRs #{Date.today}.csv"
  end

  def index
    @load_card_requests = LoadCardRequest.all.order(created_at: :desc).page params[:page]
    authorize @load_card_requests
  end

  def show
    @event = @load_card_request.event
    authorize @load_card_request

    @commentable = @load_card_request
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @event = Event.friendly.find(params[:event_id])
    @load_card_request = LoadCardRequest.new(event: @event)

    authorize @load_card_request
  end

  def edit
    authorize @load_card_request
  end

  def create
    # Load amount is in cents on the backend, but dollars on the frontend
    result_params = load_card_request_params
    result_params[:load_amount] = result_params[:load_amount].gsub(',', '').to_f * 100

    @load_card_request = LoadCardRequest.new(result_params)
    @event = Event.friendly.find(params[:load_card_request][:event_id])

    authorize @load_card_request

    load_amount = @load_card_request.load_amount

    if load_amount > @event.balance_available
      flash[:error] = "You can’t load more money than you have onto your card."
      render :new
      return
    end

    if @load_card_request.save
      flash[:success] = 'Successfully requested transfer to cards.'
      redirect_to event_cards_overview_path(@event)
    else
      render :new
    end
  end

  def update
    authorize @load_card_request

    # Load amount is in cents on the backend, but dollars on the frontend
    result_params = load_card_request_params
    result_params[:load_amount] = result_params[:load_amount].to_f * 100

    if @load_card_request.update(result_params)
      flash[:success] = 'Transfer request was successfully updated.'
      redirect_to @load_card_request
    else
      render :edit
    end
  end

  def accept
    @load_card_request.accepted_at = Time.now
    @load_card_request.fulfilled_by = current_user

    authorize @load_card_request

    if @load_card_request.save
      flash[:success] = 'Transfer accepted.'
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to load_card_requests_path
  end

  def reject
    authorize @load_card_request

    @load_card_request.rejected_at = Time.now
    if @load_card_request.save
      flash[:success] = 'Transfer rejected.'
      redirect_to @load_card_request.event
    else
      redirect_to load_card_requests_path
    end
  end

  def cancel
    authorize @load_card_request

    if @load_card_request.under_review?
      @load_card_request.canceled_at = Time.now
      if @load_card_request.save
        flash[:success] = 'Transfer canceled.'
      else
        flash[:error] = 'Failed to cancel transfer.'
      end
    else
      flash[:error] = 'Transfer cannot be canceled.'
    end

    redirect_to event_cards_overview_path(@load_card_request.event)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_load_card_request
    @load_card_request = LoadCardRequest.find(params[:id] || params[:load_card_request_id])
    @event = @load_card_request.event
  end

  # Only allow a trusted parameter "white list" through.
  def load_card_request_params
    params.require(:load_card_request).permit(:event_id, :creator_id, :load_amount, :emburse_transaction_id)
  end
end
