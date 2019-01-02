class OrganizerPositionDeletionRequestsController < ApplicationController
  before_action :set_opdr, only: [:show, :close, :open]

  def index
    authorize OrganizerPositionDeletionRequest
    @opdrs = OrganizerPositionDeletionRequest.all
  end

  def show
    authorize @opdr

    @commentable = @opdr
    @comment = Comment.new
    @comments = @commentable.comments
  end

  def new
    @op = OrganizerPosition.find(params[:organizer_id])
    @opdr = OrganizerPositionDeletionRequest.new(organizer_position: @op)
    authorize @opdr

    @target = @op.user
  end

  def create
    attributes = filtered_params
    attributes[:submitted_by] = current_user
    @opdr = OrganizerPositionDeletionRequest.new(attributes)
    @op = @opdr.organizer_position
    @target = @op.user
    @event = @op.event

    authorize @opdr

    if @opdr.save
      redirect_to @event, flash[:success] = 'Removal request accepted. We’ll be in touch shortly.'
    else
      render :new
    end
  end

  def close
    authorize OrganizerPositionDeletionRequest
    @opdr.close current_user

    redirect_to @opdr, notice: 'Removal request closed.'
  end

  def open
    authorize OrganizerPositionDeletionRequest
    @opdr.open

    redirect_to @opdr, notice: 'Removal request opened.'
  end

  private
    def set_opdr
      id = params[:organizer_position_deletion_request_id] || params[:id]
      @opdr = OrganizerPositionDeletionRequest.find(id)
    end

    def filtered_params
      params.require(:organizer_position_deletion_request).permit(:organizer_position_id, :reason, :subject_has_outstanding_expenses_expensify, :subject_has_outstanding_transactions_emburse, :subject_emails_should_be_forwarded)
    end
end
