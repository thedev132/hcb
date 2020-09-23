class DisbursementsController < ApplicationController
  before_action :set_disbursement, only: [:show, :edit, :update]

  def index
    @disbursements = Disbursement.all.order(created_at: :desc).includes(:t_transactions, :event, :source_event)
    authorize @disbursements
  end

  def show
    authorize @disbursement
  end

  def new
    @event = Event.friendly.find(params[:event_id]) if params[:event_id]
    @disbursement = Disbursement.new(event: @event)

    authorize @disbursement
  end

  def create
    result_params = disbursement_params
    result_params[:amount] = result_params[:amount].gsub(',', '').to_f * 100

    @disbursement = Disbursement.new(result_params)
    @event = Event.friendly.find(params[:disbursement][:event_id])

    authorize @disbursement

    if @disbursement.save
      redirect_to disbursements_path
    else
      render :new
    end
  end

  def edit
    authorize @disbursement
  end

  def update
    authorize @disbursement
  end

  def mark_fulfilled
    @disbursement = Disbursement.find(params[:disbursement_id])
    authorize @disbursement

    if @disbursement.update(fulfilled_at: DateTime.now)
      flash[:success] = 'Disbursement marked as fulfilled'
      if Disbursement.pending.any?
        redirect_to pending_disbursements_path
      else
        redirect_to disbursements_path
      end
    end
  end

  def reject
    @disbursement = Disbursement.find(params[:disbursement_id])
    authorize @disbursement

    if @disbursement.update(rejected_at: DateTime.now)
      flash[:error] = 'Disbursement rejected'
      redirect_to disbursements_path
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def disbursement_params
    params.require(:disbursement).permit(
      :source_event_id,
      :event_id,
      :amount,
      :name
    )
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_disbursement
    @disbursement = Disbursement.find(params[:id] || params[:disbursement_id])
    @event = @disbursement.event
  end
end
