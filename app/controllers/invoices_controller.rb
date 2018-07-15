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
      # the 1 hour wait is a result of stripe. they automatically send the
      # invoice then, there's unfortunately no way for us to speed up the
      # process right now. their support team says they're aware of this being
      # annoying & is on it, so we'll see.
      flash[:success] = 'Invoice successfully created. It will be emailed to the point of contact of the associated sponsor in 1 hour.'
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

  # form for manually marking invoices as paid
  def manual_payment
    @invoice = Invoice.find(params[:invoice_id])

    authorize @invoice
  end

  # actual action for manually marking invoices as paid
  def manually_mark_as_paid
    @invoice = Invoice.find(params[:invoice_id])

    authorize @invoice

    if @invoice.manually_mark_as_paid(current_user, params[:manually_marked_as_paid_reason])
      flash[:success] = 'Manually marked invoice as paid'
      redirect_to @invoice
    else
      render :manual_payment
    end
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
