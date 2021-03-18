class InvoicesController < ApplicationController
  before_action :set_event, only: [:index]
  skip_before_action :signed_in_user

  def all_index
    @invoices = Invoice.all.order(created_at: :desc).includes(:creator)

    authorize Invoice
  end

  def index
    @invoices = @event.invoices.order(created_at: :desc)
    @sponsor = Sponsor.new(event: @event)
    @invoice = Invoice.new(sponsor: @sponsor)
    authorize @invoices

    # from events controller
    @invoices_in_transit = (@invoices.where(payout_id: nil, status: 'paid')
      .where
      .not(payout_creation_queued_for: nil) +
      @event.invoices.joins(:payout)
      .where(invoice_payouts: { status: ('in_transit') })
      .or(@event.invoices.joins(:payout).where(invoice_payouts: { status: ('pending') })))
    amount_in_transit = @invoices_in_transit.sum(&:amount_paid)

    @stats = {
      total: @invoices.unarchived.sum(:item_amount),
      # "paid" status invoices include manually paid invoices and
      # Stripe invoices that are paid, but for which the funds are in transit
      paid: @invoices.unarchived.paid.sum(:item_amount) - amount_in_transit,
      pending: amount_in_transit,
    }
  end

  def new
    @event = Event.friendly.find(params[:event_id])
    @sponsor = Sponsor.new(event: @event)
    @invoice = Invoice.new(sponsor: @sponsor)

    authorize @invoice
  end

  def create
    invoice_params = filtered_params.except(:action, :controller, :sponsor_attributes)
    invoice_params[:item_amount] = (filtered_params[:item_amount].gsub(',', '').to_f * 100.to_i)

    @event = Event.friendly.find params[:event_id]
    sponsor_attributes = filtered_params[:sponsor_attributes].merge(event: @event)

    @sponsor = Sponsor.friendly.find_or_initialize_by(id: sponsor_attributes[:id], event: @event)
    @invoice = Invoice.new(invoice_params)
    @invoice.sponsor = @sponsor
    @invoice.creator = current_user

    authorize @invoice

    if @sponsor.update(sponsor_attributes) && @invoice.save
      flash[:success] = "Invoice successfully created and emailed to #{@invoice.sponsor.contact_email}."
      redirect_to @invoice
    else
      render :new
    end
  end

  def show
    @invoice = Invoice.friendly.find(params[:id])
    @sponsor = @invoice.sponsor
    @event = @sponsor.event
    @payout = @invoice&.payout
    @refund = @invoice&.fee_reimbursement
    @payout_t = @payout&.t_transaction
    @refund_t = @refund&.t_transaction

    @commentable = @invoice
    @comment = Comment.new
    @comments = @invoice.comments.includes(:user)

    authorize @invoice
  end

  def archive
    @invoice = Invoice.friendly.find(params[:invoice_id])

    authorize @invoice

    @invoice.archived_at = DateTime.now
    @invoice.archived_by = current_user

    if @invoice.save
      redirect_to @invoice
    else
      flash[:error] = 'Something went wrong while trying to archive this invoice!'
      redirect_to @invoice
    end
  end

  def unarchive
    @invoice = Invoice.friendly.find(params[:invoice_id])

    authorize @invoice

    @invoice.archived_at = nil
    @invoice.archived_by = nil

    if @invoice.save
      flash[:success] = 'Invoice has been un-archived.'
      redirect_to @invoice
    else
      flash[:error] = 'Something went wrong while trying to archive this invoice!'
      redirect_to @invoice
    end
  end

  private

  def filtered_params
    params.require(:invoice).permit(
      :due_date,
      :item_description,
      :item_amount,
      :sponsor_id,
      sponsor_attributes: policy(Sponsor).permitted_attributes
    )
  end

  def set_event
    @event = Event.friendly.find(params[:id] || params[:event_id])
  end
end
