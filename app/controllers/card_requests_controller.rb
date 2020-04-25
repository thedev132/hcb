class CardRequestsController < ApplicationController
  before_action :set_card_request, only: [:show, :edit, :update, :destroy]
  before_action :ensure_pending_request, only: [:update, :edit]

  def export
    authorize CardRequest

    card_requests = CardRequest.under_review

    attributes = %w{full_name user_email event_name emburse_department_id is_virtual shipping_address_street_one shipping_address_street_two shipping_address_city shipping_address_state shipping_address_zip}

    result = CSV.generate(headers: true) do |csv|
      csv << attributes.map

      card_requests.each do |cr|
        csv << attributes.map do |attr|
          if attr == 'user_email'
            cr.creator.email
          elsif attr == 'event_name'
            "##{cr.event.id} #{cr.event.name}"
          else
            cr.send(attr)
          end
        end
      end
    end

    send_data result, filename: "Pending CRs #{Date.today}.csv"
  end

  # GET /card_requests
  def index
    @card_requests = CardRequest.all.order(created_at: :desc).page params[:page]
    authorize @card_requests
  end

  # GET /card_requests/1
  def show
    authorize @card_request

    @commentable = @card_request
    @comments = @commentable.comments
    @comment = Comment.new
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
    @card_request.creator = card_request_params[:creator_id] ? User.find(card_request_params[:creator_id]) : current_user
    @event = @card_request.event

    authorize @card_request

    if @card_request.save
      flash[:success] = 'Card successfully requested!'
      redirect_to event_cards_overview_path(@event)
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
    @card_request = CardRequest.find(params[:card_request_id])
    authorize @card_request

    @card_request.canceled_at = Time.now
    if @card_request.save
      flash[:success] = 'Canceled your card request.'
    else
      flash[:error] = 'Failed to cancel card request.'
    end

    redirect_to event_cards_overview_path(@card_request.event)
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
    params.require(:card_request).permit(
      :shipping_address_street_one,
      :shipping_address_street_two,
      :shipping_address_city,
      :shipping_address_state,
      :shipping_address_zip,
      :full_name,
      :rejected_at,
      :accepted_at,
      :notes,
      :event_id,
      :is_virtual,
      :creator_id,
    )
  end
end
