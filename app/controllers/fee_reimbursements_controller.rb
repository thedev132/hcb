class FeeReimbursementsController < ApplicationController
  before_action :set_fee_reimbursement, only: [:show, :edit, :update, :destroy]

  # GET /fee_reimbursements
  def index
    @fee_reimbursements = FeeReimbursement.all
  end

  # GET /fee_reimbursements/1
  def show
  end

  # GET /fee_reimbursements/new
  def new
    @fee_reimbursement = FeeReimbursement.new
  end

  # GET /fee_reimbursements/1/edit
  def edit
  end

  # POST /fee_reimbursements
  def create
    @fee_reimbursement = FeeReimbursement.new(fee_reimbursement_params)

    if @fee_reimbursement.save
      redirect_to @fee_reimbursement, notice: 'Fee reimbursement was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /fee_reimbursements/1
  def update
    if @fee_reimbursement.update(fee_reimbursement_params)
      redirect_to @fee_reimbursement, notice: 'Fee reimbursement was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /fee_reimbursements/1
  def destroy
    @fee_reimbursement.destroy
    redirect_to fee_reimbursements_url, notice: 'Fee reimbursement was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fee_reimbursement
      @fee_reimbursement = FeeReimbursement.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def fee_reimbursement_params
      params.require(:fee_reimbursement).permit(:amount, :status, :transaction_memo)
    end
end
