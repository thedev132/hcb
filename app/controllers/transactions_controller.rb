require 'csv'

class TransactionsController < ApplicationController
  skip_before_action :signed_in_user

  def index
    authorize Transaction

    @needs_action = Transaction.needs_action
    @transactions = Transaction.order(:date).includes(:bank_account).page params[:page]
  end

  def export
    @event = Event.friendly.find(params[:event])
    @transactions = @event.transactions
    authorize @transactions

    @attributes = %w{date display_name name amount account_balance fee fee_balance link}
    @attributes_to_currency = %w{amount fee}

    name = "#{DateTime.now.strftime("%Y-%m-%d_%H:%M:%S")}_#{@event.name.to_param}_transactions"

    respond_to do |format|
      format.csv { send_data generate_csv, filename: "#{name}.csv" }
      format.json { send_data generate_json, filename: "#{name}.json" }
     end
  end

  def show
    begin
      # DEPRECATED
      @transaction = Transaction.with_deleted.find(params[:id])
      @event = @transaction.event

      @commentable = @transaction
      @comments = @commentable.comments
      @comment = Comment.new

      authorize @transaction

      render :show_deprecated
    rescue ActiveRecord::RecordNotFound => e
      @transaction = TransactionEngine::Transaction::Show.new(canonical_transaction_id: params[:id]).run
      @event = @transaction.event

      authorize @transaction
    end
  end

  def edit
    @transaction = Transaction.find(params[:id])
    authorize @transaction
    @event = @transaction.event

    # so the fee relationship fields render
    if @transaction.fee_relationship == nil
      @transaction.fee_relationship = FeeRelationship.new

      # If a new transaction is positive, we would probably charge a fee
      if @transaction.is_event_related && @transaction.amount > 0 &&
         !@transaction.potential_github? &&
         !@transaction.potential_disbursement?
        @transaction.fee_relationship.fee_applies = true
      end

      if @transaction.potential_fee_payment?
        @transaction.fee_relationship.is_fee_payment = true
      end
    end
  end

  def update
    @transaction = Transaction.find(params[:id])
    authorize @transaction

    currently_categorized = @transaction.categorized?
    fee_relationship = @transaction.fee_relationship
    current_fee_reimbursement = @transaction.fee_reimbursement

    @transaction.assign_attributes(transaction_params)

    # NOTE: @transaction is the record, .transaction is a keyword here
    @transaction.transaction do
      if !@transaction.is_event_related
        @transaction.fee_relationship = nil
        should_delete_fee_relationship = true if fee_relationship&.persisted?
      end

      if current_fee_reimbursement.nil? && @transaction.fee_reimbursement.present?
        @transaction.fee_relationship = FeeRelationship.new(
          event_id: @transaction.fee_reimbursement.event.id,
          fee_applies: true,
          fee_amount: @transaction.fee_reimbursement.calculate_fee_amount
        )
      end

      if @transaction.save
        # need to destroy the fee relationship here because we have a foreign
        # key that'll be erased on the @transaction.save
        fee_relationship.destroy! if should_delete_fee_relationship

        # if we just categorized the transaction & it's an invoice payout, send email to organizers
        if (currently_categorized != @transaction.categorized?) && @transaction.invoice_payout
          @transaction.notify_user_invoice
        end

        redirect_to @transaction
      else
        render :edit
      end
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :is_event_related,
      :emburse_transfer_id,
      :invoice_payout_id,
      :display_name,
      :fee_reimbursement_id,
      :check_id,
      :disbursement_id,
      :ach_transfer_id,
      :donation_payout_id,
      # TODO: I (@zrl) think users might be able to mess with the fee
      # relationship ID on the clientside.
      fee_relationship_attributes: [
        :id,
        :event_id,
        :fee_applies,
        :is_fee_payment
      ]
    )
  end

  def generate_json
    account_balance = @event.balance
    results = @transactions.map do |transaction|
      t = {}
      @attributes.each do |attr|
        t[attr] = case attr
        when 'account_balance'
          prev_account_balance = account_balance
          account_balance -= transaction.amount

          account_balance.to_i
        when 'fee_balance'
          previous_transactions = @transactions.select { |t| t.date <= transaction.date }

          fees_occured = previous_transactions.map { |t| t.fee_relationship.fee_applies ? t.fee_relationship.fee_amount : 0 }.sum
          fee_paid = previous_transactions.map { |t| t.fee_relationship.is_fee_payment ? t.amount : 0 }.sum

          fee_balance = fees_occured + fee_paid
        else
          transaction.send attr
        end
      end
      t
    end

    results.to_json
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << @attributes.map do |k|
        next 'Raw Name' if k == 'name'
        next 'Fiscal Sponsorship Fee' if k == 'fee'
        next 'Fiscal Sponsorship Fee Balance' if k == 'fee_balance'

        k.sub('_', ' ').gsub(/\S+/, &:capitalize)
      end

      account_balance = @event.balance

      @transactions.each do |transaction|
        csv << @attributes.map do |attr|
          if @attributes_to_currency.include? attr
            view_context.render_money transaction.send(attr)
          elsif attr == 'fee_balance'
            previous_transactions = @transactions.select { |t| t.date <= transaction.date }

            fees_occured = previous_transactions.map { |t| t.fee_relationship.fee_applies ? t.fee_relationship.fee_amount : 0 }.sum
            fee_paid = previous_transactions.map { |t| t.fee_relationship.is_fee_payment ? t.amount : 0 }.sum

            view_context.render_money (fees_occured + fee_paid)
          elsif attr == 'account_balance'
            prev_account_balance = account_balance
            account_balance -= transaction.amount

            view_context.render_money prev_account_balance
          else
            transaction.send(attr)
          end
        end
      end
    end
  end
end
