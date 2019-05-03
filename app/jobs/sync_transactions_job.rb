class SyncTransactionsJob < ApplicationJob
  RUN_EVERY = 1.hour

  def perform(repeat = false)
    ActiveRecord::Base.transaction do
      begin_date = Time.current.at_beginning_of_month
      end_date = Time.current.at_beginning_of_month.next_month

      go_to_previous_month = true

      while go_to_previous_month do
        plaid_transactions = transactions_in_range(begin_date, end_date)
        db_transactions = Transaction.where(
          'date > ? AND date < ?',
          begin_date,
          end_date
        )

        if plaid_transactions.length.zero? && db_transactions.length.zero?
          go_to_previous_month = false
          next
        end

        # will keep track of transactions in the state map. transactions that
        # are created / updated will be marked as processed.
        #
        # transactions that no longer exist in plaid will be destroyed.
        state_map = {}
        db_transactions.map { |t| state_map[t.id] = :unprocessed }

        # now that we have the transactions, do the sync
        plaid_transactions.each do |t|
          account = BankAccount.find_by(plaid_account_id: t.account_id)
          next unless account

          tr = Transaction.find_or_initialize_by(plaid_id: t.transaction_id)

          tr.update_attributes!(
            bank_account: account,
            plaid_category_id: t.category_id,
            name: t.name,
            amount: -(t.amount * 100), # convert to cents & reverse negativity
            date: t.date,
            location_address: t.location&.address,
            location_city: t.location&.city,
            location_state: t.location&.state,
            location_zip: t.location&.zip,
            location_lat: t.location&.lat,
            location_lng: t.location&.lon,
            payment_meta_by_order_of: t.payment_meta&.by_order_of,
            payment_meta_payee: t.payment_meta&.payee,
            payment_meta_payer: t.payment_meta&.payer,
            payment_meta_payment_method: t.payment_meta&.payment_method,
            payment_meta_payment_processor: t.payment_meta&.payment_processor,
            payment_meta_ppd_id: t.payment_meta&.ppd_id,
            payment_meta_reference_number: t.payment_meta&.reference_number,
            pending: t.pending,
            pending_transaction_id: t.pending_transaction_id
          )

          check_fee_reimbursement(tr)

          state_map[tr.id] = :processed
        end

        unprocessed = state_map.select { |k, v| v == :unprocessed }.map { |k, v| k }

        # for transactions that were in our db, but were not found in plaid,
        # delete them
        unprocessed.each { |tr_id| Transaction.find(tr_id).destroy }

        begin_date = begin_date.prev_month
        end_date = end_date.prev_month
      end
    end

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end

  def check_fee_reimbursement(transaction)
    FeeReimbursement.pending.each do |reimbursement|
      # match transaction to event so less work for Michael!
      if (transaction.name == reimbursement.transaction_memo)
        reimbursement.t_transaction = transaction
        transaction.fee_relationship = FeeRelationship.new(
          event_id: reimbursement.invoice.event.id,
          fee_applies: true,
          fee_amount: reimbursement.amount
        )
        transaction.display_name = "Fee reimbursement from #{reimbursement.invoice.id} invoice"
        transaction.save
      end
    end
  end

  def transactions_in_range(begin_date, end_date)
    transaction_response = PlaidService.instance.client.transactions.get(
      BankAccount.instance.plaid_access_token,
      begin_date,
      end_date
    )

    transactions = transaction_response.transactions

    while transactions.length < transaction_response['total_transactions']
      transaction_response = client.transactions.get(
        access_token,
        begin_date,
        end_date,
        offset: transactions.length
      )

      transactions += transaction_response.transactions
    end

    transactions
  end
end
