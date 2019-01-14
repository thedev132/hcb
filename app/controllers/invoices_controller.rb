class InvoicesController < ApplicationController
  before_action :set_event, only: [:index]

  def index
    @invoices = @event.invoices
    authorize Invoice
  end

  def new
    @event = Event.find(params[:event_id])
    @sponsor = Sponsor.new(event: @event)
    @invoice = Invoice.new(sponsor: @sponsor)

    authorize @invoice
  end

  def create
    filtered_params = invoice_params.except(:action, :controller)
    filtered_params[:item_amount] = (invoice_params[:item_amount].to_f * 100.to_i)

    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor ||= Sponsor.create(invoice_params[:sponsor_attributes])
    @invoice = Invoice.new(filtered_params)
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

    @commentable = @invoice
    @comment = Comment.new
    @comments = @invoice.comments

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

    reason = params[:manually_marked_as_paid_reason]
    attachment = params[:manually_marked_as_paid_attachment]

    if @invoice.manually_mark_as_paid(current_user, reason, attachment)
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
      :item_amount,
      :sponsor_id,
      sponsor_attributes: policy(Sponsor).permitted_attributes
    )
  end

  def set_event
    # TODO: needs security for if event isnt yours
    @event = @g_suite_application&.event || Event.find(params[:id] || params[:event_id])
  end
end
