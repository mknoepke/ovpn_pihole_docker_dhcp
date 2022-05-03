#!/bin/bash +x

source .env

docker-compose down

docker-compose up --no-start
docker-compose start pihole

#config
if [[ $1 -gt 1 ]]
then
  sudo rm -r ./data/server #./data/pihole*
  docker-compose start conf

  docker-compose exec conf ovpn_genconfig -d -u udp://${VPNSERVERNAMECOM} -r ${subnet}.1/24 -n ${subnet}.3/24 -t

  docker-compose exec conf ovpn_initpki nopass

  docker-compose exec conf easyrsa build-client-full ${CLIENTNAME1} nopass; docker-compose exec conf ovpn_getclient ${CLIENTNAME1} > ${CLIENTNAME1}.ovpn
  docker-compose exec conf easyrsa build-client-full ${CLIENTNAME2} nopass; docker-compose exec conf ovpn_getclient ${CLIENTNAME2} > ${CLIENTNAME2}.ovpn

else
  echo "using existing config"
fi

#run
docker-compose stop conf
docker-compose start server


docker-compose logs -f server
