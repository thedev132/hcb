web: bin/rails server -p $PORT -e production
worker: bundle exec sidekiq
worker-low: bundle exec sidekiq -q low
worker-actionmail: bundle exec sidekiq -q action_mailbox_incineration -q action_mailbox_routing
worker-activestorage: bundle exec sidekiq -q active_storage_purge -q active_storage_analysis
worker-mailers: bundle exec sidekiq -q mailers
worker-default: bundle exec sidekiq -q default
worker-critical: bundle exec sidekiq -q critical
release: bin/release-tasks
