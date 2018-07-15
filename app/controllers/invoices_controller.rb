class InvoicesController < ApplicationController
  before_action :signed_in_user

  def new
    @sponsor = Sponsor.find(params[:sponsor_id])
    @invoice = Invoice.new
  end

  def create
    @sponsor = Sponsor.find(params[:sponsor_id])

    @invoice = Invoice.new(invoice_params)
    @invoice.sponsor = @sponsor
    @invoice.creator = current_user

    authorize @invoice

    if @invoice.save
      flash[:success] = 'Invoice successfully created'
      redirect_to @invoice
    else
      render :new
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
    @sponsor = @invoice.sponsor

    authorize @invoice
  end

  private

  def invoice_params
    params.require(:invoice).permit(
      :due_date,
      :item_description,
      :item_amount
    )
  end
end
