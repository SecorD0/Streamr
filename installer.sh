#!/bin/bash
sudo apt update
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
sudo apt upgrade -y
sudo apt install wget git build-essential jq expect -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/docker_installer.sh)
mkdir $HOME/.streamrDocker
expect <<END
	set timeout 300
	spawn docker run -it -v $(cd ~/.streamrDocker; pwd):/root/.streamr streamr/broker-node:testnet bin/config-wizard
	expect "Do you want to generate"
	send -- "\n"
	expect "Select the plugins"
	send -- "a\n"
	expect "Select a port for the websocket"
	send -- "\n"
	expect "Select a port for the mqtt"
	send -- "\n"
	expect "Select a port for the publishHttp"
	send -- "\n"
	expect "Select a path to store"
	send -- "\n"
	expect eof
END
docker run -it --restart=always --name=streamr_node -d -p 7170:7170 -p 7171:7171 -p 1883:1883 -v $(cd ~/.streamrDocker; pwd):/root/.streamr streamr/broker-node:testnet
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "streamr_log" "docker logs streamr_node --follow --tail=100" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "streamr_wallet_info" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Streamr/main/wallet_info.sh) | jq" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m.\n'
echo -e 'Remember to save this file:'
echo -e "\033[0;31m$HOME/.streamrDocker/broker-config.json\e[0m\n"
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To view the node log: \e[40m\e[92mstreamr_log\e[0m'
echo -e 'To view the list of all containers: \e[40m\e[92mdocker ps -a\e[0m'
echo -e 'To delete the node container:'
echo -e '\e[40m\e[92mdocker stop streamr_node\e[0m'
echo -e '\e[40m\e[92mdocker container rm streamr_node\e[0m'
echo -e 'To restart the node: \e[40m\e[92mdocker restart streamr_node\e[0m\n'
