#!/bin/bash
echo "this script will help you install all the prereqs for using Hack Club Bank in a GitHub Codespace"

echo "chekcing ruby and bundler version"
ruby -v
bundle -v

echo "installing prereq versions"
rbenv install 2.7.3
gem install bundler:1.17.3

echo "heroku and associated al."
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
heroku git:remote -a bank-hackclub
heroku pg:backups:capture
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -d bank_development latest.dump

echo "docker install"
cp .env.docker.example .env.docker
