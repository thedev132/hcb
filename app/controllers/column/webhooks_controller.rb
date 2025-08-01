# frozen_string_literal: true

module Column
  class WebhooksController < ActionController::Base
    skip_before_action :verify_authenticity_token

    before_action :verify_signature

    def webhook
      @object = params[:data]
      type = params[:type]
      if type == "ach.incoming_transfer.scheduled"
        handle_ach_incoming_transfer_scheduled
      elsif type == "ach.incoming_transfer.settled"
        handle_as_raw_pending_column_transaction
      elsif type == "wire.incoming_transfer.completed"
        handle_as_raw_pending_column_transaction
      elsif type == "swift.incoming_transfer.completed"
        handle_as_raw_pending_column_transaction
      elsif type == "ach.outgoing_transfer.returned"
        handle_ach_outgoing_transfer_returned
      elsif type == "check.outgoing_debit.settled"
        handle_check_deposit_settled
      elsif type == "check.outgoing_debit.returned"
        handle_check_deposit_returned
      elsif type == "swift.outgoing_transfer.returned"
        handle_swift_outgoing_transfer_returned
      elsif type.start_with?("check.incoming_debit")
        handle_outgoing_check_update
      end
    rescue => e
      Rails.error.report(e)
    ensure
      head :ok
    end

    private

    def handle_ach_incoming_transfer_scheduled
      account_number = AccountNumber.find_by(column_id: @object[:account_number_id])

      return if account_number.nil? # Allow debits to non-HCB-managed account numbers

      return if (@object[:type].downcase == "credit" || @object[:amount] <= 100) && !account_number.event.financially_frozen? # Allow incoming ACH credits and small debits

      if account_number.event.financially_frozen?
        ColumnService.return_ach(@object[:id], with: ColumnService::AchCodes::STOP_PAYMENT)
      elsif account_number.deposit_only?
        ColumnService.return_ach(@object[:id], with: ColumnService::AchCodes::STOP_PAYMENT)
        AccountNumberMailer.with(event: account_number.event, memo: "#{@object["company_name"]} #{@object["company_entry_description"]}", amount_cents: @object[:amount]).debits_disabled.deliver_later
      elsif account_number.event.balance_available_v2_cents < @object[:amount]
        ColumnService.return_ach(@object[:id], with: ColumnService::AchCodes::INSUFFICIENT_BALANCE)
        AccountNumberMailer.with(event: account_number.event, memo: "#{@object["company_name"]} #{@object["company_entry_description"]}", amount_cents: @object[:amount]).insufficent_balance.deliver_later
      end

      # at this point, the ACH is approved!
    end

    def handle_as_raw_pending_column_transaction(column_event_type:)
      account_number = AccountNumber.find_by(column_id: @object[:account_number_id])
      # we only create RawPendingColumnTransaction for transactions to
      # event-specific account numbers.
      return if account_number.nil?

      RawPendingColumnTransaction.create!(
        amount_cents: @object["available_amount"],
        date_posted: @object["effective_at_utc"],
        column_transaction: @object,
        column_event_type:
      )
    end

    def handle_ach_outgoing_transfer_returned
      AchTransfer.find_by(column_id: @object[:id])&.mark_failed!(reason: @object[:return_details].pick(:description)&.gsub(/\(trace #: \d+\)\Z/, "")&.strip)
    end

    def handle_swift_outgoing_transfer_returned
      Wire.find_by(column_id: @object[:id])&.mark_failed!(@object[:return_reason]&.gsub(/\(trace #: \d+\)\Z/, "")&.strip)
    end

    def handle_outgoing_check_update
      check = IncreaseCheck.find_by(column_id: @object[:id])

      check&.update!(
        column_object: @object,
        check_number: @object[:check_number],
        column_status: @object[:status],
        column_delivery_status: @object[:delivery_status],
      )
    end

    # Column uses the "settled" state to represent when the
    # check is deposited in our bank account.
    # - @sampoder
    def handle_check_deposit_settled
      check_deposit = CheckDeposit.find_by(column_id: @object[:id])

      check_deposit&.update!(status: :deposited)
    end

    def handle_check_deposit_returned
      check_deposit = CheckDeposit.find_by(column_id: @object[:id])

      check_deposit&.update!(status: :returned)
    end

    def verify_signature
      signature_valid = ActiveSupport::SecurityUtils.secure_compare(
        OpenSSL::HMAC.hexdigest(
          "SHA256",
          Credentials.fetch(:COLUMN, ColumnService::ENVIRONMENT, :WEBHOOK_SECRET),
          request.body.read
        ),
        request.headers["Column-Signature"]
      )

      unless signature_valid
        head :bad_request
      end
    end

  end
end
