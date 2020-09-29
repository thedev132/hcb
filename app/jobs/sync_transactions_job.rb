class SyncTransactionsJob < ApplicationJob
  RUN_EVERY = 1.hour

  def perform(repeat = false)
    BankAccount.syncing.each { |bank_account| sync_account bank_account }

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end

  def sync_account(bank_account)
    puts "Syncing account '#{bank_account.name}'..."
    ActiveRecord::Base.transaction do
      transactions_sync_state = {}
      bank_account.transactions.find_each { |t| transactions_sync_state[t.id] = :not_found }

      begin_date = Time.current.at_beginning_of_month
      end_date = Time.current.at_beginning_of_month.next_month

      go_to_previous_month = true

      while go_to_previous_month do
        plaid_transactions = transactions_in_range(bank_account, begin_date, end_date)

        db_transactions = bank_account.transactions.where(
          'date > ? AND date < ?',
          begin_date,
          end_date
        )

        # This makes sure that we always have synced the month of the last transaction before we give up.
        if plaid_transactions.length.zero? && db_transactions.length.zero? && end_date < Transaction.with_deleted.first.created_at
          go_to_previous_month = false
          next
        end

        # now that we have the transactions, do the sync
        plaid_transactions.each do |t|
          next if t.pending

          tr = bank_account.transactions.with_deleted.find_or_initialize_by(plaid_id: t.transaction_id)

          transactions_sync_state[tr.id] = :on_plaid

          tr.update_attributes!(
            bank_account: bank_account,
            plaid_category_id: t.category_id,
            name: t.name,
            amount: -BigDecimal.new(t.amount.to_s) * 100, # convert to cents & reverse negativity
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
            pending_transaction_id: t.pending_transaction_id,
            deleted_at: nil
          )

          # first, try to see if it was previously paired.
          # if it wasn't, then try to auto-pair it.
          tr.try_recover_pending_tx_details!
          next unless tr.uncategorized?
          tr.try_pair_automatically!
        end

        begin_date = begin_date.prev_month
        end_date = end_date.prev_month
      end
      transactions_sync_state.each { |id, state| Transaction.find(id).destroy if state == :not_found }
    end
  end

  def transactions_in_range(account, begin_date, end_date)
    transaction_response = PlaidService.instance.client.transactions.get(
      account.plaid_access_token,
      begin_date,
      end_date,
      account_ids: [account.plaid_account_id]
    )

    transactions = transaction_response.transactions

    while transactions.length < transaction_response['total_transactions']
      transaction_response = PlaidService.instance.client.transactions.get(
        account.plaid_access_token,
        begin_date,
        end_date,
        account_ids: [account.plaid_account_id],
        offset: transactions.length
      )

      transactions += transaction_response.transactions
    end

    transactions
  rescue ::Plaid::ItemError, ::Plaid::InvalidInputError => error
    Airbrake.notify("plaid_client.transactions.get failed for bank_account #{account.id} with access token #{account.plaid_access_token}. #{error.message}")

    raise error
  end
end
