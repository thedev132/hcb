web: bin/rails server -p $PORT -e production
worker: RAILS_MAX_THREADS=5 bundle exec sidekiq
release: bin/release-tasks
