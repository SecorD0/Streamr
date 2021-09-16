#!/bin/bash
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
docker stop streamr_node
docker container rm streamr_node
docker pull streamr/broker-node:testnet
docker run -it --restart=always --name=streamr_node -d -p 7170:7170 -p 7171:7171 -p 1883:1883 -v $(cd ~/.streamrDocker; pwd):/root/.streamr streamr/broker-node:testnet
echo -e '\e[40m\e[92mDone!\e[0m'
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo ""
docker logs streamr_node --tail=30 | grep 'version'