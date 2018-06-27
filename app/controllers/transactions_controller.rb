class TransactionsController < ApplicationController
  before_action :signed_in_user

  def index
    @event = Event.find(params[:event])
    @transactions = @event.transactions

    attributes = %w{date name amount fee}

    result = CSV.generate(headers: true) do |csv|
      csv << attributes

      @transactions.each do |transaction|
        csv << attributes.map{ |attr| transaction.send(attr) }
      end
    end

    send_data result, filename: "#{@event.name} transactions #{Date.today}.csv"
  end

  def show
    @transaction = Transaction.find(params[:id])
    @fee = fee

    authorize @transaction
  end

  def edit
    @transaction = Transaction.find(params[:id])
    authorize @transaction

    # so the fee relationship fields render
    @transaction.fee_relationship ||= FeeRelationship.new
  end

  def update
    @transaction = Transaction.find(params[:id])
    authorize @transaction

    fee_relationship = @transaction.fee_relationship

    @transaction.assign_attributes(transaction_params)

    @transaction.transaction do
      if !@transaction.is_event_related
        @transaction.fee_relationship = nil
        should_delete_fee_relationship = true if fee_relationship&.persisted?
      end

      if @transaction.save
        # need to destroy the fee relationship here because we have a foreign
        # key that'll be erased on the @transaction.save
        fee_relationship.destroy! if should_delete_fee_relationship

        redirect_to @transaction
      else
        render :edit
      end
    end
  end

  private

  def fee
    @transaction.is_event_related && @transaction.fee_relationship
  end

  def transaction_params
    params.require(:transaction).permit(
      :is_event_related,
      fee_relationship_attributes: [ :event_id, :is_fee_payment ]
    )
  end
end
