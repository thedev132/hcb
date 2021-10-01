#!/bin/bash

# this script will start Hack Club Bank in a GitHub Codespace docker instance

if [ ! -e ./config/master.key ]; then
    echo "No config/master.key found; please get one from a Bank dev team member."
    exit 0
fi

echo "Loading..."

echo "Thank you for developing Hack Club Bank!"

env \$(cat .env.docker) docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000