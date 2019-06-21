#!/bin/bash


DISCORD_USERNAME="rpi"
WEBHOOK_URL="<discord web hook url>"
ALERT_DISCORD_TAG=""
LOUD_ALERT_DISCORD_TAG="@everyone "
WEBHOOK_ENABLED=false

pushd `dirname $0` > /dev/null


declare -A TUNNEL_USERS
declare -A TUNNEL_PORTS
TUNNEL_USERS=( ["rpi-liab"]="ubuntu" ["rpi-wan"]="ubuntu" ["rpi-opt1"]="ubuntu" ["rpi-opt2"]="ubuntu" ["rpi-opt3"]="ubuntu")
TUNNEL_PORTS=( ["rpi-liab"]="2223"   ["rpi-wan"]="2224"   ["rpi-opt1"]="2225"   ["rpi-opt2"]="2226"   ["rpi-opt3"]="2227")

if [[ "$1" == "-a" ]]; then
        #Update states and alert
        ALERT_ENABLED=true
        DISCORD_TAG=${ALERT_DISCORD_TAG}
elif [[ "$1" == "-A" ]]; then
        #Update states and shout the alert
        ALERT_ENABLED=true
        DISCORD_TAG=${LOUD_ALERT_DISCORD_TAG}
fi

for INTERFACE in "${!TUNNEL_PORTS[@]}"; do
        PORT=${TUNNEL_PORTS[$INTERFACE]}
        LAST_STATE=`cat states/${INTERFACE}`
        ps aufx | grep /usr/bin/ssh | grep -- "-R ${PORT}:" >/dev/null
        if [ $? -eq 0 ]; then
                CURRENT_STATE="up"
        else
                CURRENT_STATE="down"
        fi
        if [[ ! ${ALERT_ENABLED} ]]; then
                echo "${INTERFACE}($PORT) is $CURRENT_STATE"
        else
                echo ${CURRENT_STATE} > states/${INTERFACE}
                if [[ "${LAST_STATE}" == "${CURRENT_STATE}" ]]; then
                        echo "${INTERFACE}($PORT) is $CURRENT_STATE"
                else
                        echo "${INTERFACE}($PORT) is $CURRENT_STATE (Changed from $LAST_STATE)"
                        [ ${WEBHOOK_ENABLED} ] && curl -H "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_USERNAME}\", \"content\": \"${DISCORD_TAG}Interface ${INTERFACE} changed state to ${CURRENT_STATE} from ${LAST_STATE}\"}" ${WEBHOOK_URL}
                fi
        fi

done

