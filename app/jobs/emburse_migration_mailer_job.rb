class EmburseMigrationMailerJob < ApplicationJob
  def perform
    users = EmburseCardRequest.where('fulfilled_by_id IS NOT NULL').where('is_virtual IS NOT TRUE').map(&:creator).uniq

    users.select{|u| u.email == 'max@maxwofford.com'}.each do |user|
      puts "Emailing #{user.email}"
      CardMailer.with(user: user).emburse_migration.deliver_later
    end
  end
end