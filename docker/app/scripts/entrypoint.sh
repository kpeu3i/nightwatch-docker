#!/bin/bash

set -e

CMD="/scripts/wait_for.sh $NW_WAIT_FOR_HOSTS --timeout $NW_WAIT_FOR_TIMEOUT -- gosu $NW_CONTAINER_USER_NAME:$NW_CONTAINER_USER_GROUP_NAME $@"

if [ "$NW_MODE" == "debug" ]; then
    if [ "$NW_HOST_UID" == "" ] || [ "$NW_HOST_GID" == "" ]; then
        echo "Warning! Host UID or GID are not set"
    else
        echo "Mapping UID and GID..."
        /scripts/user_map.sh "$NW_HOST_UID" "$NW_HOST_GID" "$NW_CONTAINER_USER_NAME" "$NW_CONTAINER_USER_GROUP_NAME" > /dev/null 2>&1

        echo "Setting up permissions..."
        chown "$NW_CONTAINER_USER_NAME":"$NW_CONTAINER_USER_GROUP_NAME" /app
    fi
fi

export NW_HOST_IP=`netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`

exec ${CMD}
