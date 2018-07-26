class SyncEmburseTransactionsJob < ApplicationJob
  RUN_EVERY = 5.minutes

  def perform(repeat = false)
    ActiveRecord::Base.transaction do
      EmburseClient::Transaction.list.each do |trn|
        et = EmburseTransaction.find_by(emburse_id: trn[:id])
        et ||= EmburseTransaction.new(emburse_id: trn[:id])

        department_id = trn[:department] && trn[:department][:id]
        # If the transaction isn't assigned to a department directly, we'll use the card's department
        if department_id.nil? && trn[:card]
          card = EmburseClient::Card.get(trn[:card][:id])
          department_id = card[:department][:id]
        end

        amount = trn[:amount] * 100
        related_event_id = department_id ? Event.find_by(emburse_department_id: department_id).id : null

        et.update!(
          amount: amount,
          state: trn[:state],
          emburse_department_id: department_id,
          event_id: related_event_id
        )
      end
    end

    self.class.set(wait: RUN_EVERY).perform_later(true) if repeat
  end
end
