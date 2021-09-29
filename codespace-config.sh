#!/bin/bash

# this script will help you install all the prereqs for using Hack Club Bank in a GitHub Codespace

if [ ! -e ./config/master.key ]; then
    echo "No config/master.key found; please get one from a Bank dev team member."
    exit 0
fi

echo "Loading..."
(curl https://cli-assets.heroku.com/install-ubuntu.sh | sh) > /dev/null 2>&1
heroku login -i
heroku git:remote -a bank-hackclub
heroku pg:backups:capture
heroku pg:backups:download

cp .env.docker.example .env.docker

env $(cat .env.docker) docker-compose build
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails db:create db:migrate
env $(cat .env.docker) docker-compose run --service-ports web pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump

echo ""

echo "Run the below to start the docker container:"
echo "env \$(cat .env.docker) docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000"

echo "Thank you for developing Hack Club Bank!"