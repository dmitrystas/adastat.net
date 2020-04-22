#!/bin/bash

# config section
# define the config variables with your own data

# path to jcli
JCLI='./jcli'

# jormungandr rest api url
JREST_API_URL='http://127.0.0.1:3101/api'

# your pool id
POOL_ID='0000000000000000000000000000000000000000000000000000000000000000'

# path to the pool owner private key file (this is necessary to sign the data you send)
# the private key must match a public key of the pool owner
# if you need you can find the pool owner public key by clicking the "Owner" link on the https://adastat.net/pool/{POOL_ID} page
PRIVATE_KEY_FILE='./secret.key'



# core section
# usually you should not change the code below this line

BLOCK0_TIME=1576264417

SLOTS_PER_EPOCH=43200

SLOT_DURATION=2

NOW_TIME=$(date +%s)

EPOCH_DURATION=$(($SLOTS_PER_EPOCH * $SLOT_DURATION))

CURRENT_EPOCH=$((($NOW_TIME - $BLOCK0_TIME) / $EPOCH_DURATION))

BLOCKS_QUANTITY=$($JCLI rest v0 leaders logs get -h $JREST_API_URL 2>/dev/null | grep 'scheduled_at_date: "'$CURRENT_EPOCH'.' -c)

JSON='{"pool":"'$POOL_ID'","epoch":"'$CURRENT_EPOCH'","blocks":"'$BLOCKS_QUANTITY'"}'

SIGNATURE=$(echo $JSON | $JCLI key sign --secret-key $PRIVATE_KEY_FILE 2>/dev/null)

if [ ! -z "$SIGNATURE" ]; then
	echo 'Request  :' $JSON

	RESPONSE=$(curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: $SIGNATURE" -X POST --data $JSON "https://api.adastat.net/rest/v0/poolblocks.json")
	
	STATUS=$(echo "$RESPONSE" | grep '"res":true')
	
	if [ ! -z "$STATUS" ]; then
		echo -e 'Response : \033[0;32mOK\033[0m' 
	else
		echo -e 'Response : \033[0;31m'$RESPONSE'\033[0m'
	fi
else
	echo -e '\033[0;31mAn error has occurred while signing data. You should probably specify the correct PRIVATE_KEY_FILE in the config section\033[0m'
fi
