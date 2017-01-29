#!/bin/bash

CMD="/scripts/wait_for.sh $NW_WAIT_FOR_HOSTS --timeout "${NW_WAIT_FOR_TIMEOUT}" -- node"

if [ $NW_HOST_UID != "" ] && [ $NW_HOST_GID != "" ] && [ $NW_CONTAINER_USER != "" ] && [ $NW_CONTAINER_GROUP != "" ]; then
    /scripts/user_map.sh $NW_HOST_UID $NW_HOST_GID $NW_CONTAINER_USER $NW_CONTAINER_GROUP
    chown -R $NW_HOST_UID:$NW_HOST_GID /nightwatch
fi

exec ${CMD}
