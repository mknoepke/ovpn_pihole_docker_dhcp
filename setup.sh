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
  #docker-compose exec conf ovpn_genconfig -u udp://${VPNSERVERNAMECOM}
  #docker-compose exec conf ovpn_genconfig -u udp://${VPNSERVERNAMECOM} -s ${subnet}.0/24 -r ${subnet}.1/24 -d

  docker-compose exec conf ovpn_initpki nopass

  docker-compose exec conf easyrsa build-client-full ${CLIENTNAME1} nopass; docker-compose exec conf ovpn_getclient ${CLIENTNAME1} > ${CLIENTNAME1}.ovpn
  docker-compose exec conf easyrsa build-client-full ${CLIENTNAME2} nopass; docker-compose exec conf ovpn_getclient ${CLIENTNAME2} > ${CLIENTNAME2}.ovpn

  docker-compose exec conf bash -c "echo 'script-security 2'             >> /etc/openvpn/openvpn.conf"
  docker-compose exec conf bash -c "echo 'learn-address learnaddress.sh' >> /etc/openvpn/openvpn.conf"

  cd data/pihole-etc/
  sudo mkdir custom.d;
  sudo touch custom.d/ovpn
  sudo chmod 777 -R custom.d/
  sudo ln -sf custom.d/ovpn custom.list
  cd -

else
  echo "using existing config"
fi

#run
docker-compose stop conf
docker-compose start server


docker-compose logs -f server
