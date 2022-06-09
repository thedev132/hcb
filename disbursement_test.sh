# @msw: I'm using this to quickly iterate on the cpt logic for disbursements
# while in development. While harmless, this shouldn't be merged into
# production.

./docker_start.sh /bin/bash -c "
    DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:drop db:create &&
    pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump;
    bundle exec rails db:migrate"

./docker_start.sh /bin/bash -c "
    bundle exec rails runner 'PendingTransactionEngineJob::Nightly.perform_now' &&
    bundle exec rails runner 'PendingEventMappingEngineJob::Nightly.perform_now' &&
    bundle exec rails s -b 0.0.0.0 -p 3000"