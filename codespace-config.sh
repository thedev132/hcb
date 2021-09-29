#!/bin/bash
echo "this script will help you install all the prereqs for using Hack Club Bank in a GitHub Codespace"

# echo "checking ruby and bundler version"
# ruby -v
# bundle -v

# echo "installing prereq versions"
# rbenv install 2.7.3
# gem install bundler:1.17.3

echo "heroku and associated"
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
heroku login -i
heroku git:remote -a bank-hackclub
heroku pg:backups:capture
heroku pg:backups:download

echo "docker install"
cp .env.docker.example .env.docker

echo ""
env $(cat .env.docker) docker-compose build
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails db:create db:migrate
env $(cat .env.docker) docker-compose run --service-ports web pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump

echo "script finished"
