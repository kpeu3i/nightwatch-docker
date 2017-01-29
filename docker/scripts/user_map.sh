#!/bin/bash

HOST_UID=$1
HOST_GID=$2
CONTAINER_USER=$3
CONTAINER_GROUP=$4

if [ $HOST_UID != "" ] && [ $HOST_GID != "" ]; then
    if [ $HOST_UID != "0" ]; then
        HOST_UID_EXISTS=$(cat /etc/passwd | grep $HOST_UID | wc -l)
        HOST_GID_EXISTS=$(cat /etc/group | grep $HOST_GID | wc -l)

        if [ $HOST_UID_EXISTS != "0" ]; then
            EXISTS_USER_NAME=$(getent passwd $HOST_UID | cut -d: -f1)
            if [ $EXISTS_USER_NAME != $CONTAINER_USER ]; then
                MAX_UID=$(cat /etc/passwd | cut -d":" -f3 | sort -n | tail -1)
                NEW_UID=$(($HOST_UID + $MAX_UID))
                usermod -u $NEW_UID $EXISTS_USER_NAME
            fi
        fi

        if [ $HOST_GID_EXISTS != "0" ]; then
            EXISTS_GROUP_NAME=$(getent group $HOST_GID | cut -d: -f1)
            if [ $EXISTS_GROUP_NAME != $CONTAINER_GROUP ]; then
                MAX_GID=$(cat /etc/group | cut -d":" -f3 | sort -n | tail -1)
                NEW_GID=$(($HOST_UID + $MAX_GID))
                groupmod -g $NEW_GID $EXISTS_GROUP_NAME
                groupmod -g $HOST_GID $CONTAINER_GROUP
            fi
        else
            groupmod -g $HOST_GID $CONTAINER_GROUP
        fi

        usermod -u $HOST_UID $CONTAINER_USER
        usermod -g $HOST_GID $CONTAINER_GROUP
    fi
fi
