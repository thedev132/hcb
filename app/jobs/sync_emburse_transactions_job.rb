class SyncEmburseTransactionsJob < ApplicationJob
  def perform
    ActiveRecord::Base.transaction do
      # When Emburse gets a 'test' transaction (ie. AWS charges a card to make
      # sure it's valid, but removes the charge later), it will later remove the
      # transaction from their API. We want to archive any transactions that are
      # no longer on Emburse or we'll end up with a bunch of garbage transaction
      # data showing up for our users.
      #
      # NOTE: We only check for deleted transactions from the last 30 days,
      # assuming that transactions will not disappear after that time.
      # We query Emburse for TXs for the last 90 days, as a precaution, so
      # we do not accidentally delete valid transactions
      deleted_transactions = EmburseTransaction.all.pluck :emburse_id

      # We query for such a long time back because users may upload receipts or change categories on these
      # transactions, and we want to know about them. In an ideal world, we'd sync them back
      # in real time for all of history, but this is the best we do for now.
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
        # the transaction has an associated emburse_card, but no associated department
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

        # find the emburse_card and associated event
        emburse_card = EmburseCard.find_by(emburse_id: trn.dig(:card, :id))
        related_event = emburse_card.event if emburse_card

        department_id = trn.dig(:department, :id)
        department_id = emburse_card.department_id if department_id.nil? and emburse_card

        amount = (BigDecimal.new("#{trn[:amount]}") * 100).round

        et.update!(
          amount: amount,
          state: trn[:state],
          emburse_department_id: department_id,
          event: related_event || et.event,
          emburse_card_uuid: trn.dig(:card, :id),
          emburse_card: emburse_card,
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

        next if et.receipts.exists?
        next unless trn.dig(:receipt, :url) && et&.emburse_card&.user
        downloaded_receipt = open(trn.dig(:receipt, :url))
        receipt = Receipt.new(receiptable: et, uploader: et.emburse_card.user)
        receipt.file.attach(io: downloaded_receipt, filename: trn.dig(:receipt, :filename))
        receipt.save!
      end

      deleted_transactions.each { |emburse_id| EmburseTransaction.find_by(emburse_id: emburse_id).destroy }
    end
  end
end
