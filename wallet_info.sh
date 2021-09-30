#!/bin/bash
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script show JSON information about Streamr node"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help  show the help page"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Streamr/blob/main/wallet_info.sh - script URL"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Actions
sudo apt install bc -y &>/dev/null
wallet_address=$(docker logs streamr_node | grep -oPm1 "(?<=Network node 'miner-node' \(id\=)([^%]+)(?=\) running)")
wallet_info=$(wget -qO- "https://testnet1.streamr.network:3013/stats/$wallet_address")
codes_claimed=$(jq ".claimCount" <<< $wallet_info)
codes_percentage=$(jq ".claimPercentage" <<< $wallet_info)
appr_balance_DATA=`echo "$codes_claimed*0.015" | bc -l`
appr_balance_USDT=`echo "$appr_balance_DATA*$(. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/token_price.sh) -p streamr)" | bc -l`
printf_n '{"wallet_address": "%s", "codes_claimed": %d, "codes_percentage": %0.3f, "appr_balance_DATA": %0.3f, "appr_balance_USDT": %0.3f}' \
"$wallet_address" \
"$codes_claimed" \
"$codes_percentage" \
"$appr_balance_DATA" \
"$appr_balance_USDT"