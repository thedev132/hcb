class NotifyOfMigrationJob < ApplicationJob
  queue_as :default

  def perform
    users = User.includes(:emburse_cards, :organizer_positions).where.not(emburse_cards: { id: nil }, organizer_positions: { id: nil }).uniq
    users.each do |user|
      EmburseCardMailer.with(user: user).warn_of_migration.deliver_later
    end
  end
end