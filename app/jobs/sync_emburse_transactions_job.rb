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
        related_event = department_id ? Event.find_by(emburse_department_id: department_id) : nil

        et.update!(
          amount: amount,
          state: trn[:state],
          emburse_department_id: department_id,
          event: related_event
        )

        self.notify_admin(et) unless department_id
      end
    end

    self.class.set(wait: RUN_EVERY).perform_later(true) if repeat
  end

  def notify_admin(emburse_t)
    return if emburse_t.notified_admin_at

    EmburseTransactionsMailer.notify(emburse_transaction: emburse_t).deliver_later
    emburse_t.update!(notified_admin_at: Time.now)
  end

end
