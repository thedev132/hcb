#!/usr/bin/env bash

# starts the dev server with Docker
#  _   _  ____ ____
# | | | |/ ___| __ )
# | |_| | |   |  _ \
# |  _  | |___| |_) |
# |_| |_|\____|____/



echo "
     @HCB@@@@@HCB@
    T             S
  H        $        T
 E       A   C       A
B    H           K    R
U      ©   H   A      T
C      C   K   C      S
K      L   U   B      H
 @    HCB HCB HCB    E
  @                 @
    HACK FOUNDATION

HCB, A Hack Club Project
© The Hack Foundation
"

if [ ! -e ./config/master.key ]; then
    echo "No config/master.key found; please get one from a HCB dev team member."
    exit 0
fi

 echo "Thank you for developing HCB!
 "

if [[ $* == *--with-solargraph* ]]
then
  docker compose -f docker-compose.yml -f docker-compose.solargraph.yml up -d solargraph
else
  echo "To enable Solargraph, run docker_start.sh with the --with-solargraph flag."
fi

docker compose run --service-ports web "${@/--with-solargraph/''}"
