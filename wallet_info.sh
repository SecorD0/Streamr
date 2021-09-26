#!/bin/bash
sudo apt install bc -y &>/dev/null
wallet_address=$(docker logs streamr_node | grep -oPm1 "(?<=Network node 'miner-node' \(id\=)([^%]+)(?=\) running)")
wallet_info=$(wget -qO- "https://testnet1.streamr.network:3013/stats/$wallet_address")
codes_claimed=$(jq ".claimCount" <<< $wallet_info)
codes_percentage=$(jq ".claimPercentage" <<< $wallet_info)
appr_balance_DATA=`echo "$codes_claimed*0.015" | bc -l`
appr_balance_USDT=`echo "$appr_balance_DATA*0.11" | bc -l`
printf '{"wallet_address":"%s","codes_claimed":%d,"codes_percentage":%f,"appr_balance_DATA":%f,"appr_balance_USDT":%f}\n' \
"$wallet_address" \
"$codes_claimed" \
"$codes_percentage" \
"$appr_balance_DATA" \
"$appr_balance_USDT"