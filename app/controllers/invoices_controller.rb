class InvoicesController < ApplicationController
  def new
    @sponsor = Sponsor.find(params[:sponsor_id])
    @invoice = Invoice.new
  end

  def create
    @sponsor = Sponsor.find(params[:sponsor_id])

    @invoice = Invoice.new(invoice_params)
    @invoice.sponsor = @sponsor

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice successfully created'
    else
      render :new
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
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
