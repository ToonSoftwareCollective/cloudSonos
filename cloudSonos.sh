#!/bin/sh

#===================================================================================================================================================================
# This script is used to get some data for the sonos v2 app where xmlHttpRequest is not possible
# The app is started from the TSC script
#
# Version: 1.0  - oepi-loepi - 29-3-2023
#
#===================================================================================================================================================================

#VERSION-0#

# Start

echo "$(date '+%d/%m/%Y %H:%M:%S') TSC script instructed me to do some sonos"
	if [ -s /var/tmp/sonos_token.txt ]
	then
		EMAIL=`cat /var/tmp/sonos_token.txt | cut -d ";" -f 1`
		PASSW=`cat /var/tmp/sonos_token.txt | cut -d ";" -f 2`

		# 1ST REQUEST
		curl --location \
		-c /var/tmp/cookie.txt \
		'https://api.sonos.com/login/v3/oauth/selectHousehold?scope=playback-control-all&client_id=000000000000-00000000000-0000000000&response_type=code&redirect_uri=http%253A%252F%252Flocalhost&state=testState' \
		>/var/tmp/sonosstep1.txt


		#PARSE CSRF TOKEN 1ST REQUEST
		CSRF=`grep -o '"_csrf" value="[^"]*' /var/tmp/sonosstep1.txt | grep -o '[^"]*$'`
		echo "$(date '+%d/%m/%Y %H:%M:%S') -csrf found in 1st request: $CSRF"


		# 2ND REQUEST
		curl --location \
		-c /var/tmp/cookie.txt \
		-b /var/tmp/cookie.txt \
		-d "grant_type=password" \
		-d "password=$PASSW" \
		-d "_csrf=$CSRF" \
		-d "username=$EMAIL" \
		POST 'https://api.sonos.com/login/v3/signin' \
		>/var/tmp/sonosstep2.txt


		#PARSE CSRF TOKEN 2ND REQUEST
		CSRF2=`grep -o '"_csrf" value="[^"]*' /var/tmp/sonosstep2.txt | grep -o '[^"]*$'`
		echo "$(date '+%d/%m/%Y %H:%M:%S') -csrf found in 2nd request: $CSRF2"

		
		# 3RD REQUEST
		curl --location -k \
		'https://api.sonos.com/login/v3/oauth/authorize?action=submit&response_type=code&client_id=000000000000-00000000000-0000000000&state=testState&redirect_uri=http%253A%252F%252Flocalhost&scope=playback-control-all'  \
		--dump-header /var/tmp/header.txt \
		-c /var/tmp/cookie.txt \
		-b /var/tmp/cookie.txt \
		--form "_csrf=$CSRF2" \
		--form 'clientId=000000000000-00000000000-0000000000' \
		--form 'redirectUri=http://localhost' \
		--form 'responseType=code' \
		--form 'authScope=playback-control-all' \
		--form 'action=submit'\
		--form 'authState=testState' 


		#PARSE CODE FROM 3RD REQUEST
		#echo "$(date '+%d/%m/%Y %H:%M:%S') Trying to find code"
		CODE=`grep -o 'testState&code=[^=]*' /var/tmp/header.txt | grep -o '[^=]*$'`
		CODE2="`echo "$CODE" | xargs`"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Code found : $CODE2"


		#GET BEARER TOKENS FROM CODE
		curl -X POST -H "Content-Type: application/x-www-form-urlencoded;charset=utf-8" \
		-H "Authorization: Basic AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" \
		"https://api.sonos.com/login/v3/oauth/access" \
		-d "grant_type=authorization_code&code=$CODE&redirect_uri=http%3A%2F%2Flocalhost" > /var/tmp/sonosBearer.txt


		BEARER=`cat /tmp/sonosBearer.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Bearer found : $BEARER"

		rm -f /var/tmp/sonosstep1.txt
		rm -f /var/tmp/sonosstep2.txt
		rm -f /var/tmp/header.txt
		rm -f /var/tmp/sonos_token.txt
	fi
	
	if [ -s /var/tmp/sonos_refresh.txt ]
	then

		#GET BEARER TOKENS FROM REFRESH
		RFTOKEN=`cat /var/tmp/sonos_refresh.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') RFTOKEN found : $RFTOKEN"

		curl -X POST -H "Content-Type: application/x-www-form-urlencoded;charset=utf-8" \
		-H "Authorization: Basic AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" \
		"https://api.sonos.com/login/v3/oauth/access" \
		-d "grant_type=refresh_token&refresh_token=$RFTOKEN" > /var/tmp/sonosBearer.txt

		BEARER=`cat /var/tmp/sonosBearer.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Bearer found : $BEARER"

		rm -f /var/tmp/sonos_refresh.txt
	fi










