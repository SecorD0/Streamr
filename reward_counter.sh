#!/bin/bash
# Default variables
address=""

# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script calculates the size of reward from one or several Streamr node"
		echo -e "addresses. By default it creates the file ${C_LGn}addresses.txt${RES} if it doesn't exist and gets"
		echo -e "addresses from it"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help     show the help page"
		echo -e "  -a, --address  address to get reward info"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Streamr/blob/main/reward_counter.sh - script URL"
		echo -e "https://t.me/OnePackage — noderun and tech community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-a*|--address*)
		if ! grep -q "=" <<< $1; then shift; fi
		address=`option_value $1`
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
sudo apt install wget -y &>/dev/null
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
if [ ! -f addresses.txt ] && [ ! -n "$address" ]; then
	touch addresses.txt
	printf_n "${C_LGn}`pwd`/addresses.txt${RES} was created, ${C_LGn}fill it${RES}!\n"
	return 0 2>/dev/null; exit 0
fi
if [ -n "$address" ]; then
	printf_n "${C_LGn}Calculating...${RES}\n\n"
	DATA_reward=`wget -qO- https://raw.githubusercontent.com/streamr-dev/brubeck-rewards/main/rewards.csv | grep "$address" | awk -F ',' '{print $3}'`
	USDT_reward=`. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/parsers/token_price.sh) -ts data -m "$DATA_reward"`
	printf_n "${C_LGn}%s${RES} | ${C_LGn}%.2f DATA${RES} | ${C_LGn}%.2f\$${RES}\n" "$address" "$DATA_reward" "$USDT_reward"
else
	printf_n "${C_LGn}Preparation...${RES}"
	sudo apt install bc -y &>/dev/null
	table=`wget -qO- https://raw.githubusercontent.com/streamr-dev/brubeck-rewards/main/rewards.csv`
	DATA_price=`. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/parsers/token_price.sh) -ts data`
	sum_reward=0
	printf_n "${C_LGn}Calculating...${RES}\n\n"
	for address in `cat addresses.txt | tr -d '\r'`; do
		DATA_reward=`wget -qO- https://raw.githubusercontent.com/streamr-dev/brubeck-rewards/main/rewards.csv | grep "$address" | awk -F ',' '{print $3}'`
		USDT_reward=`bc <<< "$DATA_reward*$DATA_price"`
		printf_n "%s | %.2f DATA | %.2f\$" "$address" "$DATA_reward" "$USDT_reward"
		sum_reward=`bc <<< "$sum_reward+$DATA_reward"`
	done
	printf_n "\n${C_LGn}Total${RES} | ${C_LGn}%.2f DATA${RES} | ${C_LGn}%.2f\$${RES}\n" "$sum_reward" `bc <<< "$sum_reward*$DATA_price"`
fi
