#!/bin/bash

# this script will help you install all the prereqs for using Hack Club Bank in a GitHub Codespace

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 0/7: Checking for config/master.key"

if [ ! -e ./config/master.key ]; then
    echo "No config/master.key found; please get one from a Bank dev team member."
    exit 0
fi

echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "Loading..."

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 1/7: Install Heroku (Quiet)"
(curl https://cli-assets.heroku.com/install-ubuntu.sh | sh) > /dev/null 2>&1
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"
echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 2/7: Login to Heroku (Input Needed)"
(heroku auth:whoami) > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "(tput setaf 9)Hack Club Bank:$(tput sgr0) Already signed in, skipping login..."
else
  heroku login -i
fi
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"
echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 3/7: Connect to the Heroku Project"
heroku git:remote -a bank-hackclub
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"
echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 4/7: Get Heroku Backups"
heroku pg:backups:capture
heroku pg:backups:download
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 5/7: Copy Dockerfile to Docker Container"
cp .env.docker.example .env.docker
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 6/7: Docker CLI Build"
env $(cat .env.docker) docker-compose build
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"
echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 7/7: Docker Database Setup"
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails db:create db:migrate
env $(cat .env.docker) docker-compose run --service-ports web pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) 

Run 'codespace-start.sh' or the below to start the docker container:"
echo "env \$(cat .env.docker) docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000"

echo "

Thank you for developing Hack Club Bank!"

echo "
     @BANK@@@BANK@
    T             S
  H        $        T
 E       A   N       A
B    B           K    R
U      ©   H   A      T
C      C   K   C      S
K      L   U   B      H
 @    HACKCLUBANK    E
  @                 @
    HACK FOUNDATION

Hack Club Bank, A Hack Club Project
2021 The Hack Foundation
"
