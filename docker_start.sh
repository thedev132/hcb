#!/bin/bash

# starts the dev server with Docker

#   _    _            _        _____ _       _        ____              _    
#  | |  | |          | |      / ____| |     | |      |  _ \            | |   
#  | |__| | __ _  ___| | __  | |    | |_   _| |__    | |_) | __ _ _ __ | | __
#  |  __  |/ _` |/ __| |/ /  | |    | | | | | '_ \   |  _ < / _` | '_ \| |/ /
#  | |  | | (_| | (__|   <   | |____| | |_| | |_) |  | |_) | (_| | | | |   < 
#  |_|  |_|\__,_|\___|_|\_\   \_____|_|\__,_|_.__/   |____/ \__,_|_| |_|_|\_\


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

# echo -e "
# $(curl -s http://artii.herokuapp.com/make?text=Hack++Club++Bank)
# "

if [ ! -e ./config/master.key ]; then
    echo "No config/master.key found; please get one from a Bank dev team member."
    exit 0
fi

sleep 1

 echo "Loading..."

sleep 0.5

 echo "Thank you for developing Hack Club Bank!
 "

sleep 0.5

if [[ $* == *--with-solargraph* ]]
then
  env $(cat .env.docker) docker-compose -f docker-compose.yml -f docker-compose.solargraph.yml up -d solargraph
else
  echo "To enable Solargraph, run docker_start.sh with the --with-solargraph flag."
fi

sleep 0.5

# max@maxwofford.com: This is a hack to get past https://github.com/hackclub/bank/issues/2445 while developing. This isn't a long-term fix.
env $(cat .env.docker) docker-compose run --service-ports web yarn install --check-files

env $(cat .env.docker) docker-compose run --service-ports web
