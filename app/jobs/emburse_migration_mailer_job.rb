class EmburseMigrationMailerJob < ApplicationJob
  def perform
    users = EmburseCardRequest.where('fulfilled_by_id IS NOT NULL').where('is_virtual IS NOT TRUE').map(&:creator).uniq

    users.where('admin_at IS NOT NULL').each do |user|
      puts "Emailing #{user.email}"
      CardMailer.with(user: user).emburse_migration.deliver_later
    end
  end
end