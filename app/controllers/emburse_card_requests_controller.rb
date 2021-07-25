# frozen_string_literal: true

class EmburseCardRequestsController < ApplicationController
  before_action :set_emburse_card_request, only: [:show, :edit, :update, :destroy]
  before_action :ensure_pending_request, only: [:update, :edit]
  skip_before_action :signed_in_user

  def export
    authorize EmburseCardRequest

    emburse_card_requests = EmburseCardRequest.under_review

    attributes = %w{full_name user_email event_name emburse_department_id is_virtual shipping_address_street_one shipping_address_street_two shipping_address_city shipping_address_state shipping_address_zip}

    result = CSV.generate(headers: true) do |csv|
      csv << attributes.map

      emburse_card_requests.each do |cr|
        csv << attributes.map do |attr|
          if attr == "user_email"
            cr.creator.email
          elsif attr == "event_name"
            "##{cr.event.id} #{cr.event.name}"
          else
            cr.send(attr)
          end
        end
      end
    end

    send_data result, filename: "Pending CRs #{Date.today}.csv"
  end

  # GET /emburse_card_requests
  def index
    @emburse_card_requests = EmburseCardRequest.all.order(created_at: :desc).page params[:page]
    authorize @emburse_card_requests
  end

  # GET /emburse_card_requests/1
  def show
    authorize @emburse_card_request

    @commentable = @emburse_card_request
    @comments = @commentable.comments
    @comment = Comment.new
  end

  # GET /emburse_card_requests/new
  def new
    @event = Event.friendly.find(params[:event_id]) if params[:event_id]
    @emburse_card_request = EmburseCardRequest.new(event: @event)

    authorize @emburse_card_request
  end

  # GET /emburse_card_requests/1/edit
  def edit
    authorize @emburse_card_request
  end

  def reject
    @emburse_card_request = EmburseCardRequest.find(params[:emburse_card_request_id])

    authorize @emburse_card_request

    @emburse_card_request.rejected_at = Time.current
    if @emburse_card_request.save
      flash[:success] = "EmburseCard request rejected."
      redirect_to emburse_card_requests_path
    end
  end

  # POST /emburse_card_requests
  def create
    @emburse_card_request = EmburseCardRequest.new(emburse_card_request_params)
    @emburse_card_request.creator = emburse_card_request_params[:creator_id] ? User.find(emburse_card_request_params[:creator_id]) : current_user
    @event = @emburse_card_request.event

    authorize @emburse_card_request

    if @emburse_card_request.save
      flash[:success] = "EmburseCard successfully requested!"
      redirect_to event_emburse_cards_overview_path(@event)
    else
      render "new"
    end
  end

  # PATCH/PUT /emburse_card_requests/1
  def update
    authorize @emburse_card_request
    if @emburse_card_request.update(emburse_card_request_params)
      flash[:success] = "Changes to emburse_card request saved."
      redirect_to @emburse_card_request
    else
      render "edit"
    end
  end

  # POST /emburse_card_requests/1
  def cancel
    @emburse_card_request = EmburseCardRequest.find(params[:emburse_card_request_id])
    authorize @emburse_card_request

    @emburse_card_request.canceled_at = Time.now
    if @emburse_card_request.save
      flash[:success] = "Canceled your emburse_card request."
    else
      flash[:error] = "Failed to cancel emburse_card request."
    end

    redirect_to event_emburse_cards_overview_path(@emburse_card_request.event)
  end

  private

  def ensure_pending_request
    raise "Requests cannot be edited after they are accepted" if @emburse_card_request.accepted_at.present?
    raise "Requests cannot be edited after they are rejected" if @emburse_card_request.rejected_at.present?
    raise "Requests cannot be edited after they are canceled" if @emburse_card_request.canceled_at.present?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_emburse_card_request
    @emburse_card_request = EmburseCardRequest.find(params[:id] || params[:emburse_card_request_id])
    @event = @emburse_card_request.event
  end

  # Only allow a trusted parameter "white list" through.
  def emburse_card_request_params
    params.require(:emburse_card_request).permit(
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
