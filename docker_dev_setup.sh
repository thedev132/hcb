#!/usr/bin/env bash

# installs all the dependencies for using Hack Club Bank with Docker in
# development with a seeded database
# reach out to max wofford (max@hackclub.com) if you have any questions or issues.

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 0/4: Copy .env file"
cp -n .env.docker.example .env.docker
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 1/4: Build Docker Container"
env $(cat .env.docker) docker compose build
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 2/4: Docker Database Setup"
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails db:test:prepare RAILS_ENV=test
env $(cat .env.docker) docker compose run --service-ports web bundle exec rails db:create db:migrate
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 3/4: Create development user"
env $(cat .env.docker) docker compose up -d >/dev/null 2>&1
echo "Go to localhost:3000 and login to create your development user"
read -p "Press Enter to continue" </dev/tty
docker compose down
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 4/4: Development Database Seeding"
env $(cat .env.docker) docker compose run --service-ports web bundle exec rails db:seed
echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"


if [[ $* == *--with-solargraph* ]]
then
  echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) Step 5/4: Solargraph"
  env $(cat .env.docker) docker-compose -f docker-compose.yml -f docker-compose.solargraph.yml build
  echo "$(tput setaf 9)Hack Club Bank:$(tput sgr0) $(tput setaf 10)Done$(tput sgr0)"
fi

echo "
$(tput setaf 9)Hack Club Bank:$(tput sgr0)
Run 'env \$(cat .env.docker) docker-compose up' to start the dev server. You can run this command with the --with-solargraph flag to enable Solargraph."

echo "

Thank you for developing Hack Club Bank!

Questions or issues with this script? Contact Kunal Botla (kunal@hackclub.com)"

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
2022 The Hack Foundation
"
