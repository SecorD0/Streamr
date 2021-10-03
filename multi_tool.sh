#!/bin/bash
# Default variables
type="install"
completely="false"
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs, uninstalls or updates Streamr node"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help        show the help page"
		echo -e "  -up, --update     update the node"
		echo -e "  -un, --uninstall  uninstall the node"
		echo -e "  -c, --completely  uninstall the node completely (${C_R}including $HOME/.streamrDocker${RES})"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Streamr/blob/main/multi_tool.sh - script URL"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0
		;;
	-up|--update)
		type="update"
		shift
		;;
	-un|--uninstall)
		type="uninstall"
		shift
		;;
	-c|--completely)
		completely="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Actions
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
if [ "$type" = "uninstall" ]; then
	printf_n "${C_LGn}Node uninstalling...${RES}"
	containers=`docker ps -a | awk '{print $1,$2}' | grep streamr | awk '{print $1}'`
	docker stop $containers
	docker container rm $containers
	images=`docker images | awk '{print $1,$3}' | grep streamr | awk '{print $2}'`
	docker rmi $images
	if [ "$completely" = "true" ]; then
		rm -rf $HOME/.streamrDocker
	fi
	printf_n "${C_LGn}Done!${RES}\n"
elif [ "$type" = "update" ]; then
	printf_n "${C_LGn}Node updating...${RES}"
	sudo apt update
	sudo apt upgrade -y
	sudo apt install awk -y
	containers=`docker ps -a | awk '{print $1,$2}' | grep streamr | awk '{print $1}'`
	docker stop $containers
	docker container rm $containers
	docker pull streamr/broker-node:testnet
	docker run -it --restart=always --name=streamr_node -d -p 7170:7170 -p 7171:7171 -p 1883:1883 -v `cd ~/.streamrDocker; pwd`:/root/.streamr streamr/broker-node:testnet
	printf_n "${C_LGn}Done!${RES}\n"
else
	printf_n "${C_LGn}Node installation...${RES}"
	sudo apt update
	sudo apt upgrade -y
	sudo apt install git jq expect build-essential -y
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/docker.sh) --
	mkdir $HOME/.streamrDocker
	if [ -f $HOME/.streamrDocker/broker-config.json ]; then
		expect <<END
	set timeout 300
	spawn docker run -it -v `cd ~/.streamrDocker; pwd`:/root/.streamr streamr/broker-node:testnet bin/config-wizard
	expect "Do you want to generate"
	send -- "\033\[B\n"
	expect "Please provide the private key"
	send -- "`cat $HOME/.streamrDocker/broker-config.json | jq -r ".ethereumPrivateKey"`\n"
	expect "Select the plugins"
	send -- "a\n"
	expect "Provide a port for the websocket"
	send -- "\n"
	expect "Provide a port for the mqtt"
	send -- "\n"
	expect "Provide a port for the publishHttp"
	send -- "\n"
	expect "Select a path to store"
	send -- "\n"
	expect "The selected destination"
	send -- "y\n"
	expect eof
END
	else
		expect <<END
	set timeout 300
	spawn docker run -it -v `cd ~/.streamrDocker; pwd`:/root/.streamr streamr/broker-node:testnet bin/config-wizard
	expect "Do you want to generate"
	send -- "\n"
	expect "We strongly recommend"
	send -- "y\n"
	expect "Select the plugins"
	send -- "a\n"
	expect "Provide a port for the websocket"
	send -- "\n"
	expect "Provide a port for the mqtt"
	send -- "\n"
	expect "Provide a port for the publishHttp"
	send -- "\n"
	expect "Select a path to store"
	send -- "\n"
	expect eof
END
	fi
	docker run -it --restart=always --name=streamr_node -d -p 7170:7170 -p 7171:7171 -p 1883:1883 -v `cd ~/.streamrDocker; pwd`:/root/.streamr streamr/broker-node:testnet
	printf_n "${C_LGn}Done!${RES}\n"
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n "streamr_log" -v "docker logs streamr_node --follow --tail=100" -a
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n "streamr_wallet_info" -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Streamr/main/wallet_info.sh) | jq" -a
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
	printf_n "
The node was ${C_LGn}started${RES}.

Remember to save this file:
${C_LR}$HOME/.streamrDocker/broker-config.json${RES}

\tv ${C_LGn}Useful commands${RES} v

To view the node log: ${C_LGn}streamr_log${RES}
To view the list of all containers: ${C_LGn}docker ps -a${RES}
To delete the node container:
${C_LGn}docker stop streamr_node${RES}
${C_LGn}docker container rm streamr_node${RES}
To restart the node: ${C_LGn}docker restart streamr_node${RES}
"
fi