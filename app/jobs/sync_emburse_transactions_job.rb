class SyncEmburseTransactionsJob < ApplicationJob
  RUN_EVERY = 5.minutes

  def perform(repeat = false)
    ActiveRecord::Base.transaction do
      # When Emburse gets a 'test' transaction (ie. AWS charges a card to make
      # sure it's valid, but removes the charge later), it will later remove the
      # transaction from their API. We want to archive any transactions that are
      # no longer on Emburse or we'll end up with a bunch of garbage transaction
      # data showing up for our users.
      deleted_transactions = EmburseTransaction.all.pluck :emburse_id

      EmburseClient::Transaction.list.each do |trn|
        et = EmburseTransaction.find_by(emburse_id: trn[:id])
        et ||= EmburseTransaction.new(emburse_id: trn[:id])

        # Emburse has a feature called "Personal Expenses" that allows users to
        # spend money on Emburse cards, but then credit the organization back
        # for the amount (ex. if the user accidentally puts a meal on their
        # Emburse card).
        #
        # As of March 21, 2019, they don't expose whether a transaction is a
        # personal expense through the API, meaning we have to use heuristics
        # to figure out whether a transaction is a personal expense.
        #
        # My (Zach)'s best attempt after trial and error is to check whether
        # the transaction has an associated card, but no associated department
        # (bc personal expenses don't have associated departments). I've tested
        # this as a filter for all transactions and the only ones returned are
        # personal expenses, so I'm going to go with this method for now.
        next if trn[:department] == nil && trn[:card] != nil

        # Emburse transactions will sometimes post as $0 & update to their correct value later.
        # We want to skip over them until they settle on their correct amount
        #
        # Note: by skipping over them, we're not removing them from the deleted_transactions
        # array, meaning their corresponding transaction will be removed if it exists.
        next if trn[:amount] == 0 && (et.amount == nil || et.amount == 0)

        # Transaction is above 0.0 and exists, so we want to keep it around
        deleted_transactions.delete(trn[:id])

        department_id = trn.dig(:department, :id)
        card = Card.find_by(emburse_id: trn.dig(:card, :id))
        # If the transaction isn't assigned to a department directly, we'll use the card's department
        department_id = card.department_id if department_id.nil? and card

        amount = trn[:amount] * 100
        related_event = department_id ? Event.find_by(emburse_department_id: department_id) : nil

        et.update!(
          amount: amount,
          state: trn[:state],
          emburse_department_id: department_id,
          event: related_event || et.event,
          emburse_card_id: trn.dig(:card, :id),
          card: card,
          merchant_mid: trn.dig(:merchant, :mid),
          merchant_mcc: trn.dig(:merchant, :mcc),
          merchant_name: trn.dig(:merchant, :name),
          merchant_address: trn.dig(:merchant, :address),
          merchant_city: trn.dig(:merchant, :city),
          merchant_state: trn.dig(:merchant, :state),
          merchant_zip: trn.dig(:merchant, :zip),
          category_emburse_id: trn.dig(:category, :id),
          category_url: trn.dig(:category, :url),
          category_code: trn.dig(:category, :code),
          category_name: trn.dig(:category, :name),
          category_parent: trn.dig(:category, :parent),
          label: trn[:label],
          location: trn[:location],
          note: trn[:note],
          receipt_url: trn.dig(:receipt, :url),
          receipt_filename: trn.dig(:receipt, :filename),
          transaction_time: trn[:time]
        )
      end

      deleted_transactions.each { |emburse_id| EmburseTransaction.find_by(emburse_id: emburse_id).destroy }
    end

    self.class.set(wait: RUN_EVERY).perform_later(true) if repeat
  end
end
