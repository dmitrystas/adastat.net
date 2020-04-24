#!/bin/bash

#------------------------------------------------------
# config section
# please define the config variables with your own data
#------------------------------------------------------

# path to jcli
JCLI='./jcli'

# jormungandr rest api url
JREST_API_URL='http://127.0.0.1:3101/api'

# your pool id
POOL_ID='0000000000000000000000000000000000000000000000000000000000000000'

# the private key for sign data you send
# you might use the node's KES private key (sig_key in the node's secret file)
# or any other bech32 private key (for cases when signing with the KES key is not possible)
# # echo -n $(jcli key generate --type=Ed25519) > adastat.prv
# please make sure that there are no spaces or new lines in this file
PRIVATE_KEY_FILE='./stake_pool_kes.prv'
## PRIVATE_KEY_FILE='./adastat.prv'

# the public key for verify data you send
# this is only necessary if you have the separate key pairs
# # echo -n $(jcli key to-public --input adastat.prv) > adastat.pub
# otherwise, this variable must be empty (recommended)
# please make sure that there are no spaces or new lines in this file
PUBLIC_KEY_FILE=''
## PUBLIC_KEY_FILE='./adastat.pub'

# the public key signed by KES private key
# this is only necessary if you have the separate key pairs
# # jcli key sign --secret-key stake_pool_kes.prv adastat.pub > adastat.sig
# otherwise, this variable must be empty (recommended)
# please make sure that there are no spaces or new lines in this file
SIGN_KEY_FILE=''
## SIGN_KEY_FILE='./adastat.sig'

#-------------------------------------------------------
# core section
# usually you should not change the code below this line
#-------------------------------------------------------

BLOCK0_TIME=1576264417

SLOTS_PER_EPOCH=43200

SLOT_DURATION=2

NOW_TIME=$(date +%s)

EPOCH_DURATION=$(($SLOTS_PER_EPOCH * $SLOT_DURATION))

CURRENT_EPOCH=$((($NOW_TIME - $BLOCK0_TIME) / $EPOCH_DURATION))

BLOCKS_QUANTITY=$($JCLI rest v0 leaders logs get -h $JREST_API_URL 2>/dev/null | grep 'scheduled_at_date: "'$CURRENT_EPOCH'.' -c)

if [ ! -z $PUBLIC_KEY_FILE ] && [ ! -z $SIGN_KEY_FILE ]; then
	PUBLIC_KEY=$(cat $PUBLIC_KEY_FILE)

	SIGN_KEY=$(cat $SIGN_KEY_FILE)

	JSON='{"pool":"'$POOL_ID'","epoch":"'$CURRENT_EPOCH'","blocks":"'$BLOCKS_QUANTITY'","pk":"'$PUBLIC_KEY'","sig":"'$SIGN_KEY'"}'
else
	JSON='{"pool":"'$POOL_ID'","epoch":"'$CURRENT_EPOCH'","blocks":"'$BLOCKS_QUANTITY'"}'
fi

# option -n is mandatory
SIGNATURE=$(echo -n $JSON | $JCLI key sign --secret-key $PRIVATE_KEY_FILE 2>/dev/null)

if [ ! -z $SIGNATURE ]; then
	echo 'Request  :' $JSON

	RESPONSE=$(curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: $SIGNATURE" -X POST --data $JSON "https://api.adastat.net/rest/v0/poolblocks.json")
	
	STATUS=$(echo $RESPONSE | grep '"res":true')
	
	if [ ! -z $STATUS ]; then
		echo -e 'Response : \033[0;32mOK\033[0m' 
	else
		echo -e 'Response : \033[0;31m'$RESPONSE'\033[0m'
	fi
else
	echo -e '\033[0;31mAn error has occurred while signing data. You should probably specify the correct PRIVATE_KEY_FILE in the config section\033[0m'
fi
