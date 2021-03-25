class InvoicesController < ApplicationController
  before_action :set_event, only: [:index]
  skip_before_action :signed_in_user

  def all_index
    @invoices = Invoice.all.order(created_at: :desc).includes(:creator)

    authorize Invoice
  end

  def index
    relation = @event.invoices
    relation = relation.paid_v2 if params[:filter] == "paid"
    relation = relation.unpaid if params[:filter] == "unpaid"
    relation = relation.archived if params[:filter] == "archived"

    @invoices = relation.order(created_at: :desc)

    @sponsor = Sponsor.new(event: @event)
    @invoice = Invoice.new(sponsor: @sponsor)
    authorize @invoices

    # from events controller
    @invoices_in_transit = (@invoices.paid_v2.where(payout_id: nil)
      .where
      .not(payout_creation_queued_for: nil) +
      @event.invoices.joins(:payout)
      .where(invoice_payouts: { status: ('in_transit') })
      .or(@event.invoices.joins(:payout).where(invoice_payouts: { status: ('pending') })))
    amount_in_transit = @invoices_in_transit.sum(&:amount_paid)

    @stats = {
      total: @invoices.sum(:item_amount),
      # "paid" status invoices include manually paid invoices and
      # Stripe invoices that are paid, but for which the funds are in transit
      paid: @invoices.paid_v2.sum(:item_amount) - amount_in_transit,
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
    @event = Event.friendly.find(params[:event_id])

    authorize @event, policy_class: InvoicePolicy

    sponsor_attrs = filtered_params[:sponsor_attributes]

    due_date = Date::civil(filtered_params["due_date(1i)"].to_i, 
                           filtered_params["due_date(2i)"].to_i, 
                           filtered_params["due_date(3i)"].to_i)

    attrs = {
      event_id: params[:event_id],
      due_date: due_date,
      item_description: filtered_params[:item_description],
      item_amount: filtered_params[:item_amount],
      current_user: current_user,

      sponsor_id: sponsor_attrs[:id],
      sponsor_name: sponsor_attrs[:name],
      sponsor_email: sponsor_attrs[:contact_email],
      sponsor_address_line1: sponsor_attrs[:address_line1],
      sponsor_address_line2: sponsor_attrs[:address_line2],
      sponsor_address_city: sponsor_attrs[:address_city],
      sponsor_address_state: sponsor_attrs[:address_state],
      sponsor_address_postal_code: sponsor_attrs[:address_postal_code]
    }
    @invoice = ::InvoiceService::Create.new(attrs).run

    flash[:success] = "Invoice successfully created and emailed to #{@invoice.sponsor.contact_email}."

    redirect_to @invoice
  rescue => e
    @event = Event.friendly.find(params[:event_id])
    @sponsor = Sponsor.new(event: @event)
    @invoice = Invoice.new(sponsor: @sponsor)

    redirect_to new_event_invoice_path(@event), flash: { error: e.message }
  end

  def show
    @invoice = Invoice.friendly.find(params[:id])
    authorize @invoice

    @sponsor = @invoice.sponsor
    @event = @sponsor.event
    @payout = @invoice&.payout
    @refund = @invoice&.fee_reimbursement
    @payout_t = @payout&.t_transaction
    @refund_t = @refund&.t_transaction

    # Comments
    @hcb_code = HcbCode.find_by(hcb_code: @invoice.hcb_code)
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
