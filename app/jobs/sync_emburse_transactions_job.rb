class SyncEmburseTransactionsJob < ApplicationJob
  RUN_EVERY = 10.minutes

  def perform(*args)
    transactions = EmburseClient::Transaction.list
    transactions.each do |trn|
      et = EmburseTransaction.find_by(emburse_id: trn[:id])
      et ||= EmburseTransaction.new(emburse_id: trn[:id])

      amount = trn[:amount] * 100
      department_id = trn[:department] && trn[:department][:id]
      related_event = Event.find_by(emburse_department_id: department_id)

      et.update!(
        amount: amount,
        state: trn[:state],
        emburse_department_id: department_id,
        event: related_event
      )
    end
  end
end
