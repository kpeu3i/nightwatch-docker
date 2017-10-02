#!/bin/bash

CMD="/scripts/wait_for.sh $NW_WAIT_FOR_HOSTS --timeout $NW_WAIT_FOR_TIMEOUT -- nightwatch $@"

if [ "$NW_HOST_UID" != "" ] && [ "$NW_HOST_GID" != "" ]; then
    echo "Mapping UID and GID..."
    /scripts/user_map.sh "$NW_HOST_UID" "$NW_HOST_GID" "$NW_CONTAINER_USER" "$NW_CONTAINER_GROUP" > /dev/null 2>&1

    echo "Setting up permissions..."
    chown -R "$NW_HOST_UID":"$NW_HOST_GID" /nightwatch
fi

exec ${CMD}
